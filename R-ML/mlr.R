library(ggpubr)
library(dplyr)
library(caret)
library(broom)
library(tibble)
library(psych)
library(MASS)
library(units)
library(xtable)
library(relimp)
library(magrittr)
library(relaimpo)
library(stringr)

#import the preprocessed and variable encoded data file
zeolite_df <- read.table("C:/Users/DrewX/Documents/Project-Roger-Dodger/Python-ML/ZeoX_Final_encoded.tsv", sep ="\t", header = T)

dim(zeolite_df)

#reference dataset for numerical columns
zeolite_ref <- read.table("C:/Users/DrewX/Documents/Project-Roger-Dodger/Python-ML/zeolite_ref.txt", sep ="\t", header = T)
# ref_numeric <- zeolite_ref %>% select_if(is.numeric)
# numuric_cols <- colnames(ref_numeric)
#zeolite_df <-  zeolite_df %>% dplyr::select(!!num_cols)

#Check how this standardisation affects the encoded variables 
Scaler <- preProcess(zeolite_df, method = c("center", "scale"))

zeolite<- predict(Scaler, zeolite_df)

dim(zeolite)



############################## MLR #######################################
setwd("C:/Users/DrewX/Documents/Project-Roger-Dodger/R-ML/plots/multiple")

#zeolite <- zeolite[-c(23,83,299,300),]

dim(zeolite)


model1 <- lm(Capacity ~ . , data = zeolite)


init_fit <-  tidy(model1) %>% column_to_rownames("term")  %>% arrange(p.value)

init_fit

nrow(init_fit)


#residuals vs fitted
#https://online.stat.psu.edu/stat462/node/117/
#https://www.scribbr.com/statistics/multiple-linear-regression/

#Q-Q plot
#https://stats.stackexchange.com/questions/101274/how-to-interpret-a-qq-plot
#https://data.library.virginia.edu/understanding-q-q-plots/

#https://stats.stackexchange.com/questions/58141/interpreting-plot-lm
#http://127.0.0.1:29988/help/library/stats/help/Distributions

par(mfrow=c(2,2))

pdf("lm_diag_pre_stepAIC.pdf")

plot(model1)

dev.off()

zeolite_mlr <- tidy(model1) %>% 
               arrange(desc(estimate)) %>% 
               data.frame() %>% 
               mutate_if(is.numeric, round, 6)

zeolite_mlr

zeolite_mlr[zeolite_mlr$term %in% colnames(zeolite_ref),] %>% 
                 data.frame() %>%
                 filter(p.value <= 0.05) %>%
                 column_to_rownames("term") %>%
                 round(7)
  
################################################################################

stepwise_mlr <- stepAIC(model1, direction = "both")

best_fit1 <-  tidy(stepwise_mlr) %>% column_to_rownames("term")  %>% arrange(p.value)

best_fit1

nrow(best_fit1)


################################################################################
#Code below obtained from R in action book
#manning.com/books/r-in-action

relweights <- function(fit,...){
  R <- cor(fit$model)
  nvar <- ncol(R)
  rxx <- R[2:nvar, 2:nvar]
  rxy <- R[2:nvar, 1]
  svd <- eigen(rxx)
  evec <- svd$vectors
  ev <- svd$values
  delta <- diag(sqrt(ev))
  lambda <- evec %*% delta %*% t(evec)
  lambdasq <- lambda ^ 2
  beta <- solve(lambda) %*% rxy
  rsquare <- colSums(beta ^ 2)
  rawwgt <- lambdasq %*% beta ^ 2
  import <- (rawwgt / rsquare) * 100
  import <- as.data.frame(import)
  row.names(import) <- names(fit$model[2:nvar])
  names(import) <- "Weights"
  import <- import[order(import),1, drop=FALSE]
  dotchart(import$Weights, labels=row.names(import),
           xlab="% of R-Square", pch=19,
           main="Relative Importance of Predictor Variables",
           sub=paste("Total R-Square=", round(rsquare, digits=3)),
           ...)
  return(import)
}

################################# MLR analysis #################################
#https://www.linkedin.com/pulse/how-find-most-important-variables-r-amit-jain

best_model_cols <- colnames(zeolite)[colnames(zeolite) %in% row.names(best_fit1)]

best_model_cols

length(best_model_cols)

best_model_zeolite <- zeolite[c(best_model_cols, "Capacity")]

dim(best_model_zeolite)
  
fit2 <- lm(Capacity ~ . , data = best_model_zeolite )

rel_importanceW <- relweights(fit2)

rel_impoX <- rel_importanceW %>%
             rownames_to_column("Predictor")
   

################################################################################

units_df <-  read.table("C:/Users/DrewX/Documents/Project-Roger-Dodger/Python-ML/zeolites_units.txt", na.strings = "", row.names = 1, sep ="\t", stringsAsFactors = F, header = T)
full_names  <- t(units_df) %>%
               data.frame( stringsAsFactors = FALSE) %>%
               rownames_to_column(var = "symbol")


zeo_prop <- cbind(c("SA","Vmicro","Vmeso","pore_size","Si_Al"),
                         c("Na","Ag","Ce","Cu","Ni","Zn","Cs"),
                          c("C_0","oil_adsorbent_ratio","Temp")) %>%
                     data.frame() %>%
                     magrittr::set_names(c("Zeolite properties","Metal ion","Prcess condition")) 
                                     
zeo_prop

                     
zeo_cat <-  zeolite_ref %>% select_if(Negate(is.numeric))
zeo_cat <- zeo_cat[colSums(!(is.na(zeo_cat))) > 0]
colnames(zeo_cat)[2] <- "Adsorbate"

rel_impoX$group <-  NA

rel_impoX


assign_group <- function(category_df, assign_col, data){

  
for (category in colnames(category_df)){
    names <- category_df[category] %>% distinct()
    data$group[data[,assign_col] %in% names[,category]] <- category
  
}

  return(data)
}


rel_impoX <- assign_group(zeo_cat,'Predictor', rel_impoX)
rel_impoX <- assign_group(zeo_prop,'Predictor', rel_impoX)


rel_impoX

for (predictor in rel_impoX$Predictor){
  
  if(predictor %in% full_names$symbol){
    
    fnamex <- full_names$Fullname[full_names$symbol == predictor] 
    rel_impoX[rel_impoX$Predictor == predictor,]$Predictor <- fnamex
  }
}


rel_impoX <- rel_impoX %>%  
  mutate(Predictor =  Predictor %>% 
           stringr::str_replace("\\.","-"))  


rel_impoX$group[rel_impoX$Predictor == "HFAU-5"] <- "Adsorbent"
rel_impoX$group[rel_impoX$Predictor == NA ] <- "Solvent"


# ggdotchart(dfm, x = "name", y = "mpg",
#            color = "cyl",                                # Color by groups
#            sorting = "ascending",                        # Sort value in descending order
#            add = "segments",                             # Add segments from y = 0 to dots
#            ggtheme = theme_pubr()                        # ggplot2 theme
# )
# 
# 
# 
# 
# 
# ################################################################################
# 
# 
# summary(fit2)
# 
# par(mfrow=c(2,2))
# 
# pdf("lm_diag_post_stepAIC.pdf")
# 
# plot(fit2)
# 
# dev.off()
# 
# sigma(fit2)/mean(best_model_zeolite$Capacity)
# 
# confint(fit2) 
# 
# metrics <- augment(fit2)
# 
# best_fit_metrics <-  tidy(fit2) %>% column_to_rownames("term")  %>% arrange(desc(estimate)) %>% round(6)
# 
# best_fit
# 
# 
# 
# relImportance <- calc.relimp(fit2)
# #relImportance <- calc.relimp(fit2, type = "lmg", rela = TRUE)
# 
# 
# 
# print(relImportance)
# 
# print(xtable(best_fit2, digits=5, type = "latex"), file = "beest_fit_mlr_numeric.tex")
# 
# write.table(best_fit2, "best_fit2_numeric.tsv", sep ="\t", quote = F)
# 
# model_statistics <- glance(fit2)
# getwd()
# 
# write.table(model_statistics,"mlr_statics_numeric.tsv", sep ="\t", row.names = F, quote = F)
# 
# ##########################################################################################
# 
# lm_metrics <- augment(lm_fit) %>% data.frame()
# lm_stats <- tidy(lm_fit)
# 
# #plot pairwise regression
# #visualise the distrubution of points around fitted line
# print(">>>Regression line with residuals")
# ggplot(lm_metrics, aes_string(x = term, y = response_var)) +
#   geom_point(size = 1.5) + 
#   geom_smooth(method = "lm", se = FALSE, size = 1, formula = y ~ x) +      
#   geom_segment(aes_string(xend = term, yend = ".fitted"), color = "red", size = 0.5) +
#   stat_poly_eq(formula = y ~ x, 
#                aes(label =  paste(stat(rr.label), stat(p.value.label), sep = "*\", \"*")), 
#                size = 3, parse = TRUE, label.y = "top", label.x = "right") +
#   theme(panel.grid.minor = element_blank(),
#         panel.background = element_blank(),
#         axis.text = element_text(size=30, colour = "black"),
#         axis.title = element_text(size=30, colour = "black"),
#         panel.border = element_rect(colour = "black", fill=NA, size=1))
# 
# res_fname = paste0(term,  "_pw_regres.pdf")
# ggsave(res_fname)
# 
# if (length(dev.list()!=0)) {dev.off()}
# 
# #Save model statistic
# model_data <- glance(lm_fit) %>% dplyr::select(r.squared, statistic, p.value)
# model_data <- cbind(term, model_data)
# model_entries <- rbind(model_entries, model_data)
# print(model_entries)
# 
# summary(model2)
# 
# shapiro.test(resid(model2)) 
# 
# plot(model2, 1)
# 
# plot(model2, 2)
# 
# plot(model2, 3)
# 
# plot(model2, 4)
# 
# plot(model2, 5)
# 
# 
# mlr2 <- tidy(model2) %>% arrange(p.value) %>% data.frame()
# 
# mlr2
# 
# m1r2_sig <- mlr2 %>% column_to_rownames("term") %>%
#             round(6) %>%
#             arrange(p.value)
# 
# 
# 
# mlr_df <- mlr %>% column_to_rownames("term") %>%
#   round(6) %>%
#   arrange(p.value)
# 
# write.table(mlr_df, "multiple_regress.tsv", sep = "\t", quote = F)
# 
# 
# m1r1_sig <- mlr[mlr$term %in% colnames(zeolite_ref),] %>% 
#   data.frame() %>%
#   filter(p.value <= 0.05) %>%
#   column_to_rownames("term") %>%
#   round(7)
# 
# print(xtable(model_table, digits=5, type = "latex"), file = "Zeolite_PW_models.tex")

################################################################################
#Numeric data only
# Residual standard error: 0.5782 on 293 degrees of freedom
# Multiple R-squared:  0.6496,	Adjusted R-squared:  0.6389 
# F-statistic: 60.36 on 9 and 293 DF,  p-value: < 2.2e-16
# Ce           0.727957  0.048780  14.923348 0.000000
# C_0          0.369518  0.034391  10.744579 0.000000
# pore_size    0.276053  0.078893   3.499075 0.000539
# Vmicro       0.167634  0.050310   3.332041 0.000973
# Ag           0.069534  0.035005   1.986378 0.047923
# (Intercept) -0.021414  0.033437  -0.640429 0.522394
# Si_Al       -0.133975  0.042450  -3.156090 0.001765
# Vmeso       -0.179864  0.037378  -4.811987 0.000002
# Temp        -0.262532  0.042672  -6.152267 0.000000
# Cu          -0.559248  0.053833 -10.388637 0.000000




################################################################################
# data(swiss)
# 
# fit_test <- lm(Fertility ~ .,data = swiss)
# 
# summary(fit_test)
# 
# 
# (relImportnc <- calc.relimp(formula = Capacity ~ ., data = best_model_zeolite, type = "lmg", rela = TRUE))
# 
# (relImportnc <- calc.relimp(formula = Fertility ~ ., data = swiss, type = "lmg", rela = TRUE))
# 
# install.packages(parallel)

