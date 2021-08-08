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
library(tidyr)

#import the preprocessed and variable encoded data file
zeolite_df <- read.table("C:/Users/DrewX/Documents/Project-Roger-Dodger/Python-ML/ZeoX_Final_encoded.tsv", sep ="\t", header = T)

dim(zeolite_df)

#reference dataset for numerical columns
zeolite_ref <- read.table("C:/Users/DrewX/Documents/Project-Roger-Dodger/Python-ML/zeolites database catagories V 2.txt", sep ="\t", header = T)
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


(best_model_metrics <-  tidy(fit2) %>% 
                       arrange(desc(estimate)) %>% 
                       data.frame() %>%
                       column_to_rownames(var = "term"))
  
dim(best_model_metrics)

full_names <-  t(read.table("C:/Users/DrewX/Documents/Project-Roger-Dodger/Python-ML/zeolitesfeb10_names.txt", na.strings = "", row.names = 1, sep ="\t", stringsAsFactors = F, header = T))

model_table_MLR   <-   merge(x = best_model_metrics, y = full_names, by = 0, all.x = T) %>% 
                       data.frame(stringsAsFactors = F)


model_table_MLR$Fullname <- as.character(model_table_MLR$Fullname)   

model_table_MLR[is.na(model_table_MLR$Fullname),]$Fullname <- model_table_MLR[is.na(model_table_MLR$Fullname),]$Row.names
                                                              
model_table_MLR <- model_table_MLR %>%
                    dplyr::select(Fullname, estimate, std.error, statistic, p.value) %>%
                    arrange(desc(estimate))
          
          

################################ Relative importance ###########################


rel_importanceW <- relweights(fit2)

rel_impoX <- rel_importanceW %>%
             rownames_to_column("Predictor")
   

################################################################################

units_df <-  read.table("C:/Users/DrewX/Documents/Project-Roger-Dodger/Python-ML/zeolitesfeb10_names.txt", na.strings = "", row.names = 1, sep ="\t", stringsAsFactors = F, header = T)
full_names  <- t(units_df) %>%
               data.frame( stringsAsFactors = FALSE) %>%
               rownames_to_column(var = "symbol")




adsobernt_properties = c('SA', 'Vmicro', 'Vmeso', 'pore_size', 'Si_Al') 
metal_properties     = c('m1', 'm2', 'm3', 'C1', 'C2', 'C3', 'x1', 'x2', 'x3', 'Ri1', 'Ri2', 'Ri3')
adsorbate_property   = c('adsorbate', 'dipole_moment', 'chemical_hardness', 'kinetic_diameter') 
conditions           =  c('C_0', 'solvent', 'oil_adsorbent_ratio', 'Temp')

zeo_prop  <-     cbind( c('SA', 'Vmicro', 'Vmeso', 'pore_size', 'Si_Al'),
                 c('C1', 'C2', 'C3', 'x1', 'x2', 'x3', 'Ri1', 'Ri2', 'Ri3'),
                 c('dipole_moment', 'chemical_hardness', 'kinetic_diameter'),
                 c('C_0', 'oil_adsorbent_ratio', 'Temp')) %>%
                 data.frame(stringsAsFactors = F) %>%
                 magrittr::set_names(c("Adsorbent property","Metal property","Adsorbate property","Process condition"))


# zeo_prop <- cbind(c("SA","Vmicro","Vmeso","pore_size","Si_Al"),
#                          c("Na","Ag","Ce","Cu","Ni","Zn","Cs"),
#                           c("C_0","oil_adsorbent_ratio","Temp")) %>%
#                      data.frame() %>%
#                      magrittr::set_names(c("Zeolite properties","Metal ion","Prcess condition")) 
                                     
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


#rel_impoX$group[rel_impoX$Predictor == "HFAU-5"] <- "Adsorbent"
#rel_impoX$group[rel_impoX$Predictor == NA ] <- "Solvent"

rel_impoX$group  <- factor(rel_impoX$group,   levels = unique(rel_impoX$group))




ggbarplot(rel_impoX, x = "Predictor", y = "Weights",
          fill = "group", 
          xlab = "Variable",
          ylab=expression(paste('Relative importance (% of R'^2,')')),
          color = "white",            
          palette = "d3",            
          sort.val = "desc",           
          sort.by.groups = TRUE,
          x.text.angle = 90, 
          ggtheme = theme(panel.grid.minor = element_blank(),
               panel.background = element_blank(),
               axis.text.y = element_text(size=16, colour = "black"),
               axis.text.x = element_text(size=16, colour = "black", vjust = 0.5),
               axis.title = element_text(size=16, colour = "black"),
               legend.title = element_text(size = 16),
               legend.text = element_text(size = 16),
               panel.border = element_rect(colour = "black", fill=NA, size=1))
          ) + labs(fill = "Variable type")

          
ggsave("mlr_variable_importance.pdf")

          
          