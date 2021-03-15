library(ggpubr)
library(dplyr)
library(caret)
library(broom)
library(tibble)
library(psych)
library(MASS)
library(units)


#import
zeolite_df <- read.table("C:/Users/DrewX/Documents/Project-Roger-Dodger/Python-ML/ZeoX_Final_encoded.tsv", sep ="\t", header = T)

dim(zeolite_df)

#reference dataset for numerical columns
zeolite_ref <- read.table("C:/Users/DrewX/Documents/Project-Roger-Dodger/Python-ML/zeolite_ref.txt", sep ="\t", header = T)

ref_numeric <- zeolite_ref %>% select_if(is.numeric)

Scaler <- preProcess(zeolite_df, method = c("center", "scale"))

zeolite<- predict(Scaler, zeolite_df)

dim(zeolite)



############################## Linearity test ##################################################

setwd("C:/Users/DrewX/Documents/Project-Roger-Dodger/R-ML/plots/linearity/")

units_df <-  read.table("C:/Users/DrewX/Documents/Project-Roger-Dodger/Python-ML/zeolitesfeb10_units.txt", row.names = 1, sep ="\t", stringsAsFactors = F, header = T)
install_symbolic_unit("ratio")
install_symbolic_unit("mgS")






############################## MLR #######################################

model1 <- lm(Capacity ~ . , data = zeolite)

summary(model1)
#residuals vs fitted
#https://online.stat.psu.edu/stat462/node/117/

#Q-Q plot
#https://stats.stackexchange.com/questions/101274/how-to-interpret-a-qq-plot
#https://data.library.virginia.edu/understanding-q-q-plots/

#https://stats.stackexchange.com/questions/58141/interpreting-plot-lm
#http://127.0.0.1:29988/help/library/stats/help/Distributions
plot(model1)

mlr <- tidy(model1) %>% arrange(p.value)

m1r_sig <- mlr %>% column_to_rownames("term") %>%
            round(6) %>%
            arrange(p.value)



mlr_df <- mlr %>% column_to_rownames("term") %>%
        round(6) %>%
        arrange(p.value)

write.table(mlr_df, "multiple_regress.tsv", sep = "\t", quote = F)


m1r1_sig <- mlr[mlr$term %in% colnames(zeolite_ref),] %>% 
                 data.frame() %>%
                 filter(p.value <= 0.05) %>%
                 column_to_rownames("term") %>%
                 round(7)

model1  






################################################################################

stepwise_mlr <- stepAIC(model1)

best_model1 <-  tidy(stepwise_mlr) %>% column_to_rownames("term")  %>% arrange(p.value)

best_model1

nrow(best_model1)

################################################################################

best_model_cols <- colnames(zeolite)[colnames(zeolite) %in% row.names(best_model1)]

best_model_cols

best_model_zeolite <- zeolite[c(best_model_cols, "Capacity")]

dim(best_model_zeolite)
  
model2 <- lm(log(Capacity) ~ . , data = best_model_zeolite )

summary(model2)

plot(model2, 1)

plot(model2, 3)

plot(model2, 2)

mlr2 <- tidy(model2) %>% arrange(p.value) %>% data.frame()

mlr2

m1r2_sig <- mlr2 %>% column_to_rownames("term") %>%
            round(6) %>%
            arrange(p.value)



mlr_df <- mlr %>% column_to_rownames("term") %>%
  round(6) %>%
  arrange(p.value)

write.table(mlr_df, "multiple_regress.tsv", sep = "\t", quote = F)


m1r1_sig <- mlr[mlr$term %in% colnames(zeolite_ref),] %>% 
  data.frame() %>%
  filter(p.value <= 0.05) %>%
  column_to_rownames("term") %>%
  round(7)




# > summary(model2)
# 
# Call:
#   lm(formula = log(Capacity) ~ ., data = best_model_zeolite)
# 
# Residuals:
#   Min      1Q  Median      3Q     Max 
# -3.4116 -0.1728  0.0916  0.3628  1.3065 
# 
# Coefficients: (7 not defined because of singularities)
# Estimate Std. Error t value Pr(>|t|)    
# (Intercept)     2.43269    1.65859   1.467  0.14805    
# SA              1.83347    0.98208   1.867  0.06715 .  
# Vmicro          0.13366    0.46398   0.288  0.77435    
# Si_Al           1.45230    0.67321   2.157  0.03529 *  
#   Na             11.88505    4.01296   2.962  0.00448 ** 
#   Ag              0.30535    0.14009   2.180  0.03351 *  
#   Ce              2.19479    2.48794   0.882  0.38146    
# Ni              0.08629    0.09762   0.884  0.38052    
# Zn              0.17463    0.10442   1.672  0.10003    
# Cs             -1.68808    0.59198  -2.852  0.00608 ** 
#   ppm             1.91924    0.38992   4.922 7.91e-06 ***
#   Temp           -0.31897    0.27778  -1.148  0.25573    
# AgY             0.63675    0.35138   1.812  0.07533 .  
# CeY                  NA         NA      NA       NA    
# CuAgY           1.21088    0.37062   3.267  0.00186 ** 
#   CuICeIVY       -1.12553    1.99518  -0.564  0.57492    
# CuIY                 NA         NA      NA       NA    
# CuX            -1.46269    0.71473  -2.046  0.04541 *  
#   CuY            -2.42908    1.08157  -2.246  0.02867 *  
#   HFAU.5          0.48495    0.15415   3.146  0.00265 ** 
#   NaY                  NA         NA      NA       NA    
# NiCeY                NA         NA      NA       NA    
# clinoptilolite       NA         NA      NA       NA    
# TP             -0.38501    0.18100  -2.127  0.03783 *  
#   ETHER           1.24855    0.50726   2.461  0.01695 *  
#   n.Octane             NA         NA      NA       NA    
# n.heptane            NA         NA      NA       NA    
# ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
# 
# Residual standard error: 0.8417 on 56 degrees of freedom
# (95 observations deleted due to missingness)
# Multiple R-squared:  0.7199,	Adjusted R-squared:  0.6249 
# F-statistic: 7.576 on 19 and 56 DF,  p-value: 1.428e-09
#cooksd <- cooks.distance(model2)
  
  
