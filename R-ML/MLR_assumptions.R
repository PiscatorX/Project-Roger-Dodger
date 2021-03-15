library(ggplot2)
library(ggforce)
library(broom)
library(xtable)
library(ggpmisc)
library(dplyr)



 
zeolite_df <- read.table("C:/Users/DrewX/Documents/Project-Roger-Dodger/Python-ML/ZeoX_Final_encoded.tsv", sep ="\t", header = T)
zeolite_df_nounits <- read.table("C:/Users/DrewX/Documents/Project-Roger-Dodger/Python-ML/ZeoX_Final_encoded.tsv", sep ="\t", header = T)

zeolite_ref <- read.table("C:/Users/DrewX/Documents/Project-Roger-Dodger/Python-ML/zeolite_ref.txt", sep ="\t", header = T)
units_df <-  read.table("C:/Users/DrewX/Documents/Project-Roger-Dodger/Python-ML/zeolitesfeb10_units.txt", row.names = 1, sep ="\t", stringsAsFactors = F, header = T)
ref_numeric <- zeolite_ref %>% select_if(is.numeric)

dim(zeolite_df)

install_symbolic_unit("ratio")
install_symbolic_unit("mgS")

for (col in names(ref_numeric)){
  
  units(zeolite_df[,col]) <- units_df["Units", col]
  
  print(head(zeolite_numeric[col]))
  
} 



############################## Density plots  ##################################
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
  
      fmla = reformulate(termlabels = term,  response = response_var) 
      
      #linear model regression
      lm_fit =  lm(Capacity ~ SA, data = data)
      
      ##Assessing linearity
      
      lm_res_fname = paste0(term,  "_lm_res.pdf")
      #save figure to file
      pdf(lm_res_fname)
      plot(lm_fit, 
           which  = 1, 
           caption = paste(response_var, term, sep = " ~ "),
           cex.caption = 1.5,
           cex.axis = 1.5,
           cex.lab = 1.5,
           col = "blue",
           pch = 1,
           lwd = 2,
           sub.caption = "")
      
      dev.off()
      
      
      
      
      
      #extract model data
      lm_metrics <- augment(lm_fit)
      lm_stats <- tidy(lm_fit)
      head(lm_metrics)
      
      fmla <- Capacity ~ SA
      
      #plot pairwise regression
      #visualise the distrubution of points around fitted line
      ggplot(lm_metrics, aes(x = SA, y = Capacity)) +
             geom_point(size = 2) +
             geom_smooth(method = lm, se = FALSE, size = 2, formula = fmla) +
             geom_segment(aes_string(xend = term, yend = ".fitted"), color = "red", size = 1) +
        stat_poly_eq(formula = fmla,
                     aes(label = paste(..eq.., rr.label.., sep = "~~~")),
                     parse = TRUE) +
        theme(panel.grid.minor = element_blank(),
              panel.background = element_blank(),
              axis.text = element_text(size=30, colour = "black"),
              axis.title = element_text(size=30, colour = "black"),
              panel.border = element_rect(colour = "black", fill=NA, size=1))
      
      res_fname = paste0(term,  "_pw_regres.pdf")

      ggsave(res_fname)
      
      dev.off()
      
      
      model_data <- glance(lm_fit) %>% dplyr::select(r.squared, statistic, p.value)
      model_data <- cbind(term, model_data)
      model_entries <- rbind(model_entries, model_data)
      print(model_entries)
      
      #dev.off()
      diag_fname = paste0(term,  "_lm_diag.pdf")
      pdf(diag_fname)
      par(mfrow=c(2,2))
      plot(lm_fit)
      dev.off()
      
      
     
     
      return(model_entries)
      
}




cols = c('r.squared', 'statistic', 'p.value')
model_table = data.frame(matrix(ncol = length(cols), nrow = 0)) 
colnames(model_table) <- cols


for (col in colnames(ref_numeric)){
 
  model_table = ggplotPW_regress(term = col)
  
}

model_table <- model_table %>% arrange(p.value)
print(xtable(model_table, digits=5, type = "latex"), file = "Zeolite_PW_models.tex")
  

















library(ggplot2)
# generate artificial data
set.seed(4321)

my.data <- lm_metrics %>% data.frame()


# give a name to a formula
formula <- Capacity ~ SA
# plot
ggplot(my.data, aes(SA, Capacity)) +
  geom_point() +
  geom_smooth(method = "lm", formula = formula) +
  stat_poly_eq(formula = formula, parse = TRUE)








# ggplot(fit$model, aes_string(x = names(fit$model)[2], y = names(fit$model)[1])) + 
#     geom_point() +
#     stat_smooth(method = "lm", col = "red") +
#     labs(title = paste("Adj R2 = ",signif(summary(fit)$adj.r.squared, 5),
#                        "Intercept =",signif(fit$coef[[1]],5 ),
#                        " Slope =",signif(fit$coef[[2]], 5),
#                        " P =",signif(summary(fit)$coef[2,4], 5)))