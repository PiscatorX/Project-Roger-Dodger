library(ggplot2)
library(units)
library(ggforce)
library(broom)
library(xtable)
library(ggpmisc)
library(dplyr)
library(magrittr)
library(reshape2)



#https://www.dataquest.io/blog/understanding-regression-error-metrics/
zeolite_df <- read.table("C:/Users/DrewX/Documents/Project-Roger-Dodger/Python-ML/ZeoX_Final_encoded.tsv", sep ="\t", header = T)
zeolite_df_nounits <- read.table("C:/Users/DrewX/Documents/Project-Roger-Dodger/Python-ML/ZeoX_Final_encoded.tsv", sep ="\t", header = T)

zeolite_ref <- read.table("C:/Users/DrewX/Documents/Project-Roger-Dodger/Python-ML/zeolites_ref2x.tsv", sep ="\t", header = T)
units_df <-  read.table("C:/Users/DrewX/Documents/Project-Roger-Dodger/Python-ML/zeolitesfeb10_units.txt", row.names = 1, sep ="\t", stringsAsFactors = F, header = T)
ref_numeric <- zeolite_ref %>% select_if(is.numeric)

dim(zeolite_df)

install_symbolic_unit("ratio")
install_symbolic_unit("mgS")
install_symbolic_unit("D")
install_symbolic_unit("ev")


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


#lapply(colnames(ref_numeric), plot_ggdensity,  data = zeolite_df, units_df = units_df)
setwd("C:/Users/DrewX/Documents/Project-Roger-Dodger/R-ML/plots/simple")
############################ simple linear regression ##########################
zeo_dat <- ref_numeric %>%
  dplyr::select(-Capacity)


simple_lr <- function(term, response_var = "Capacity",  data = zeolite_df_nounits){
    
    print(term)
    fmla = as.formula(paste(response_var, term,  sep = " ~ ")) 
    lm_fit =  lm(fmla, data = data)
    res <- shapiro.test(resid(lm_fit))
    res$variable <- term
    
  return(res)
}


dfs <- lapply(colnames(zeo_dat), simple_lr) 

dfx <- do.call( rbind, dfs) %>% 
       data.frame() %>%
       select(variable, statistic, p.value)


units_df <-  read.table("C:/Users/DrewX/Documents/Project-Roger-Dodger/Python-ML/zeolitesfeb10_names.txt", na.strings = "", row.names = 1, sep ="\t", stringsAsFactors = F, header = T)

Fullname <- t(units_df) %>% 
            data.frame() %>%
            rownames_to_column(var = "variable")

dfx_fname <-  merge(Fullname, dfx)  %>%
              select(Fullname, statistic, p.value)

print(xtable(dfx_fname, digits=7, type = "latex"), file = "dfx.tex")




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

colnames(zeolite_df)

rownames(model_table) <- model_table$term

full_names <-  t(read.table("C:/Users/DrewX/Documents/Project-Roger-Dodger/Python-ML/zeolitesfeb10_names.txt", na.strings = "", row.names = 1, sep ="\t", stringsAsFactors = F, header = T))

model_table <- merge(full_names, model_table, by = 0, all = T) %>% 
               data.frame() %>%
               dplyr::select(Fullname, r.squared, statistic, p.value) %>%
               arrange(desc(r.squared))

print(xtable(model_table, digits=5, type = "latex"), file = "Zeolite_PW_models.tex")

#########################################################################################################################
setwd("C:/Users/DrewX/Documents/Project-Roger-Dodger/R-ML/plots/corrplot")
#setwd("/home/drewx/Documents/Project-Roger-Dodger/R-ML/plots/corrplot")

zeolite <- read.table("/home/drewx/Documents/Project-Roger-Dodger/Python-ML/", sep ="\t", header = T)

zeolite_ref <- read.table("/home/drewx/Documents/Project-Roger-Dodger/Python-ML/zeolite_ref.txt", sep ="\t", header = T)

units_df <-  read.table("/home/drewx/Documents/Project-Roger-Dodger/Python-ML/zeolitesfeb10_units.txt", row.names = 1, sep ="\t", stringsAsFactors = F, header = T)

ref_numeric <- zeolite_ref %>% select_if(is.numeric)


colnames(ref_numeric)

adsobernt_properties = c('SA', 'Vmicro', 'Vmeso', 'pore_size', 'Si_Al') 
metal_properties     = c('m1', 'm2', 'm3', 'C1', 'C2', 'C3', 'x1', 'x2', 'x3', 'Ri1', 'Ri2', 'Ri3')
adsorbate_property   = c('adsorbate', 'dipole_moment', 'chemical_hardness', 'kinetic_diameter') 
conditions           =  c('C_0', 'solvent', 'oil_adsorbent_ratio', 'Temp')



model_table %>%
       arrange(desc(r.squared))

model_table[model_table$term %in% adsobernt_properties,] %>%
                                  arrange(desc(r.squared))

model_table[model_table$term %in% metal_properties,] %>%
                                 arrange(desc(r.squared))

model_table[model_table$term %in% adsorbate_property,] %>%
                              arrange(desc(r.squared))

model_table[model_table$term %in% conditions,] %>%
                          arrange(desc(r.squared))


ref_numeric <- zeolite_ref %>% select_if(is.numeric)
numeric_cols <- colnames(ref_numeric)

zeolite_numx <- zeolite %>%
                    select(!!numeric_cols)



for (col in names(ref_numeric)){
  units(zeolite_numx[,col]) <- units_df["Units", col]
  
} 



plot_scatterlm <- function(col_var, data, units_df){
  
  p<-ggplot(data= data, aes_string(x = col_var, y = "Capacity")) +
    xlab(label = units_df["Fullname", col_var]) +
    geom_point(size = 4, colour = "#000080", alpha = 0.5) + 
    geom_smooth(method = "lm", size = 2, formula = y ~ x, colour = "red") +      
    stat_poly_eq(formula = y ~ x, 
                 aes(label =  paste(stat(rr.label), stat(p.value.label), sep = "*\", \"*")), 
                 size = 6, parse = TRUE, label.y = "top", label.x = "left") +
    coord_cartesian(clip = 'off') +
    theme(panel.grid.minor = element_blank(),
          plot.margin = margin(0.25, 0.3, 0.25, 0.3, "cm"),
          panel.background = element_blank(),
          axis.text = element_text(size=26, colour = "black"),
          axis.title = element_text(size=26, colour = "black"),
          panel.border = element_rect(colour = "black", fill=NA, size=1))
    
  fname = paste0(col_var,  "_scatter.pdf")
  print(p)
  ggsave(fname)
  
}

lapply(colnames(zeolite_numx), plot_scatterlm,  data = zeolite_numx, units_df = units_df)

plot_scatterlm("SA", data = zeolite_numx, units_df = units_df)

