library(dplyr)
library(caret)
library(broom)
library(tibble)


#import
zeolite_df <- read.table("C:/Users/DrewX/Documents/Project-Roger-Dodger/Python-ML/ZeoX_Final_encoded.tsv", sep ="\t", header = T)

dim(zeolite_df)

#reference dataset for numerical columns
zeolite_ref <- read.table("C:/Users/DrewX/Documents/Project-Roger-Dodger/Python-ML/zeolite_ref.txt", sep ="\t", header = T)

ref_numeric <- zeolite_ref %>% select_if(is.numeric) 

zeolite_numeric  <- zeolite_df[,colnames(zeolite_df) %in% colnames(ref_numeric)] 

zeolite_category  <- zeolite_df[,!colnames(zeolite_df) %in% colnames(ref_numeric)] 

Scaler <- preProcess(zeolite_numeric, method = c("center", "scale"))

zeolite_numeric <- predict(Scaler, zeolite_numeric)

dim(zeolite_numeric)
dim(zeolite_category)

zeolite <- cbind(zeolite_numeric, zeolite_category)

dim(zeolite)


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
linear_regression <- tidy(model1) %>% arrange(p.value)

linear_regression %>% 
        filter(p.value <= 0.05) %>%
        column_to_rownames("term") %>%
        round(6)

linear_regression[!linear_regression$term %in% colnames(zeolite_category),] %>% 
                 data.frame() %>%
                 filter(p.value <= 0.05) %>%
                 column_to_rownames("term") %>%
                 round(7)
par(mfrow=c(2,2))

plot(model1)                 
                 
        
