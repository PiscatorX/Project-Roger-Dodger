RF_var_importance <- read.table("/home/drewx/Documents/Project-Roger-Dodger/Python-ML/RF_feature_importance.tsv", header = T)


RF_var_importance  %>% filter(importance_mean >= 0.01)
colSums(RF_var_importance[,c(2:3)])

sum <- colSums(RF_var_importance[RF_var_importance$importance_mean > 0.01,c(2:3)])
sum(RF_var_importance$importance_mean)
