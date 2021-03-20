library(ggplot2)
library(units)
library(ggforce)
library(broom)
library(xtable)
library(ggpmisc)
library(dplyr)



#https://www.dataquest.io/blog/understanding-regression-error-metrics/
zeolite_df <- read.table("C:/Users/DrewX/Documents/Project-Roger-Dodger/Python-ML/ZeoX_Final_encoded.tsv", sep ="\t", header = T)
zeolite_df_nounits <- read.table("C:/Users/DrewX/Documents/Project-Roger-Dodger/Python-ML/ZeoX_Final_encoded.tsv", sep ="\t", header = T)

zeolite_ref <- read.table("C:/Users/DrewX/Documents/Project-Roger-Dodger/Python-ML/zeolite_ref.txt", sep ="\t", header = T)
units_df <-  read.table("C:/Users/DrewX/Documents/Project-Roger-Dodger/Python-ML/zeolitesfeb10_units.txt", row.names = 1, sep ="\t", stringsAsFactors = F, header = T)
ref_numeric <- zeolite_ref %>% select_if(is.numeric)

dim(zeolite_df)

install_symbolic_unit("ratio")
install_symbolic_unit("mgS")

#This assigns units to the variables and makes for a nice 
for (col in names(ref_numeric)){
  
  units(zeolite_df[,col]) <- units_df["Units", col]
  
} 

head(zeolite_df)



############################## Density plots  ##################################
setwd("C:/Users/DrewX/Documents/Project-Roger-Dodger/R-ML/plots/density_plots")

#http://people.duke.edu/~rnau/testing.htm#linearity
#https://sejohnston.com/2012/08/09/a-quick-and-easy-function-to-plot-lm-results-in-r/
#https://www.researchgate.net/post/Is_there_a_test_to_identify_non-linear_time_series

plot_ggdensity <- function(col_var, data, units_df){
  
  print(c(col_var,units_df["Fullname", col_var]))
  ggplot(data= data, aes_string(y = col_var)) +
    geom_density() +
    coord_flip() + 
    ylab(label = units_df["Fullname", col_var]) +
    theme(panel.grid.minor = element_blank(),
          panel.background = element_blank(),
          axis.text = element_text(size=20, colour = "black"),
          axis.title = element_text(size=20, colour = "black"),
          panel.border = element_rect(colour = "black", fill=NA, size=1))
  
  fname = paste0(col_var, "_density.pdf")
  
  ggsave(fname)
  
}


lapply(colnames(ref_numeric), plot_ggdensity,  data = zeolite_df, units_df = units_df)


############################## Pairwise relationships ##########################
setwd("C:/Users/DrewX/Documents/Project-Roger-Dodger/R-ML/plots/simple/lm_assumptions_test/")

#http://www.sthda.com/english/articles/39-regression-model-diagnostics/161-linear-regression-assumptions-and-diagnostics-in-r-essentials/

ggplotPW_regress <- function (term, response_var = "Capacity",  data = zeolite_df_nounits, model_entries = model_table) {
  
  
  #formular for the simple linear model
  fmla = as.formula(paste(response_var, term,  sep = " ~ ")) 
  #linear modelling using above formular
  lm_fit =  lm(fmla, data = data)
  
  print(">>>Residuals vs Fitted values plot")
  lm_res_fname = paste0(term,  "_lm_res.pdf")
  #save figure to file
  #sometimes the graphics devices is not closed
  if (length(dev.list()!=0)) {dev.off()}
  pdf(lm_res_fname)
  plot(lm_fit, 
       which  = 1, 
       caption = paste(paste(response_var, term,  sep = " ~ "),"(Residuals vs Fitted)"),
       cex.caption = 1.5,
       cex.axis = 1.75,
       cex.lab = 1.75,
       col = "blue",
       pch = 1,
       lwd = 2,
       sub.caption = "")
  
  if (length(dev.list()!=0)) {dev.off()}
  
  
  print(">>> Q-Q plot")
  lm_res_fname = paste0(term,  "_lm_qq.pdf")
  #save figure to file
  pdf(lm_res_fname)
  plot(lm_fit,
       which  = 2,
       caption = "", 
       main = paste(paste(response_var, term,  sep = " ~ "),"(Normal Q-Q plot)"), 
       cex.caption = 1.5,
       cex.axis = 1.65,
       cex.lab = 1.75,
       col = "red",
       pch = 1,
       lwd = 2,
       sub.caption = "")
  
  if (length(dev.list()!=0)) {dev.off()}
  
  
  #extract model data
  lm_metrics <- augment(lm_fit) %>% data.frame()
  lm_stats <- tidy(lm_fit)
  
  #plot pairwise regression
  #visualise the distrubution of points around fitted line
  print(">>>Regression line with residuals")
  ggplot(lm_metrics, aes_string(x = term, y = response_var)) +
    geom_point(size = 1.5) + 
    geom_smooth(method = "lm", se = FALSE, size = 1, formula = y ~ x) +      
    geom_segment(aes_string(xend = term, yend = ".fitted"), color = "red", size = 0.5) +
    stat_poly_eq(formula = y ~ x, 
                 aes(label =  paste(stat(rr.label), stat(p.value.label), sep = "*\", \"*")), 
                 size = 3, parse = TRUE, label.y = "top", label.x = "right") +
    theme(panel.grid.minor = element_blank(),
          panel.background = element_blank(),
          axis.text = element_text(size=30, colour = "black"),
          axis.title = element_text(size=30, colour = "black"),
          panel.border = element_rect(colour = "black", fill=NA, size=1))
  
  res_fname = paste0(term,  "_pw_regres.pdf")
  ggsave(res_fname)
  
  if (length(dev.list()!=0)) {dev.off()}
  
  #Save model statistic
  model_data <- glance(lm_fit) %>% dplyr::select(r.squared, statistic, p.value)
  model_data <- cbind(term, model_data)
  model_entries <- rbind(model_entries, model_data)
  print(model_entries)
}




cols = c('r.squared', 'statistic', 'p.value')
model_table = data.frame(matrix(ncol = length(cols), nrow = 0)) 
colnames(model_table) <- cols


for (col in colnames(ref_numeric)){
  
  model_table = ggplotPW_regress(term = col)
  
}

model_table <- model_table %>% arrange(p.value)
print(xtable(model_table, digits=5, type = "latex"), file = "Zeolite_PW_models.tex")


