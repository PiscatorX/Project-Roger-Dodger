rm(list=ls())

library(dplyr)
library(tidyverse)
library(corrplot)
library(ggplot2)
library(gridExtra)
library(ggforce)
library(units)
library(ggcorrplot)
library(RColorBrewer)
library(GGally)
library(corrplot)
library(caret)
library(wesanderson)
library(reshape2)
library(ggpubr)


zeolite <- read.table("C:/Users/DrewX/Documents/Project-Roger-Dodger/Python-ML/zeolites database catagories V 2.txt", sep ="\t", header = T)

units_df <-  read.table("C:/Users/DrewX/Documents/Project-Roger-Dodger/Python-ML/zeolitesfeb10_units.txt", row.names = 1, sep ="\t", stringsAsFactors = F, header = T)

zeolite_numeric <- zeolite %>% select_if(is.numeric)

dim(zeolite_numeric)
  
zeolite_categorical <- zeolite[,!(zeolite %in% zeolite_numeric)]

install_symbolic_unit("ratio")
install_symbolic_unit("mgS")
install_symbolic_unit("ratio")
install_symbolic_unit("ev")
install_symbolic_unit("D")




for (col in names(zeolite_numeric)){
  
  units(zeolite_numeric[,col]) <- units_df["Units", col]
  
  print(head(zeolite_numeric[col]))
  
} 


setwd("C:/Users/DrewX/Documents/Project-Roger-Dodger/R-ML/plots/boxwhisker")

########################Continuous variables####################################


plot_ggbox <- function(col_var, data, units_df){
  
  print(c(col_var,units_df["Fullname", col_var]))
  ggplot(data= data, aes_string(y = col_var)) +
    ylab(label = units_df["Fullname", col_var]) +
    stat_boxplot(geom='errorbar', linetype=1,  width = 0.35) +
    geom_boxplot(outlier.colour="#56B4E9", fill = "#56B4E9", width = 0.5) +
    theme(panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        axis.text = element_text(size=12, colour = "black"),
        axis.title = element_text(size=12, colour = "black"),
        axis.ticks.x = element_blank(),
        axis.text.x = element_blank(),
        panel.border = element_rect(colour = "black", fill=NA, size=1))
  fname = paste0(col_var, sep = ".", "pdf")
  
  ggsave(fname, height = 45, width = 50, units = "mm")

}



#plot_ggbox("C1", data = zeolite_numeric, units_df = units_df)

lapply(colnames(zeolite_numeric), plot_ggbox,  data = zeolite_numeric, units_df = units_df)


###########################Categorical variables#######################################################
setwd("C:/Users/DrewX/Documents/Project-Roger-Dodger/R-ML/plots/categorical")


dim(zeolite_categorical)


adsorbent_perc <- zeolite_categorical %>% 
                  group_by(Adsorbent) %>% 
                  summarise(count=n()) %>%
                  mutate(perc = 100 * round(count/sum(count),3)) 

ggdotchart(data = adsorbent_perc, x = "Adsorbent", y = "perc",
          color = "Adsorbent",                                
          sorting = "descending",                       
          add = "segments",
          add.params = list(color = "lightgray", size = 2),
          rotate = TRUE,                               
          dot.size = 10,
          ylab = "Dataset represation (%)",
          label = adsorbent_perc$perc,                       
          font.label = list(color = "black", size = 11, 
                           vjust = 0.5),               
          ggtheme = theme(panel.grid.minor = element_blank(),
                          panel.background = element_blank(),
                          axis.text = element_text(size=16, colour = "black"),
                          axis.title = element_text(size=20, colour = "black"),
                          axis.ticks.x = element_blank(),
                          axis.text.x = element_blank(),
                          legend.position = 'none',
                          panel.border = element_rect(colour = "black", fill=NA, size=1)))



ggsave("Adsorbent_representation.pdf", height = 179, width = 179, units = "mm")



solvent_perc <- zeolite_categorical %>% 
                  group_by(solvent) %>% 
                  summarise(count=n()) %>%
                  mutate(perc = 100 * round(count/sum(count),3)) 

ggdotchart(data = solvent_perc, x = "solvent", y = "perc",
           color = "solvent",                                
           sorting = "descending",                       
           add = "segments",
           add.params = list(color = "lightgray", size = 2),
           rotate = TRUE,                               
           dot.size = 10,
           xlab = "Solvent",
           ylab = "Dataset represation (%)",
           label = solvent_perc$perc,                       
           font.label = list(color = "black", size = 11, 
                             vjust = 0.5),               
           ggtheme = theme(panel.grid.minor = element_blank(),
                           panel.background = element_blank(),
                           axis.text = element_text(size=16, colour = "black"),
                           axis.title = element_text(size=20, colour = "black"),
                           axis.ticks.x = element_blank(),
                           axis.text.x = element_blank(),
                           legend.position = 'none',
                           panel.border = element_rect(colour = "black", fill=NA, size=1))) 

ggsave("Solvent_representation.pdf", height = 179, width = 179, units = "mm")



adsorbate_perc <- zeolite_categorical %>% 
  group_by(adsorbate) %>% 
  summarise(count=n()) %>%
  mutate(perc = 100 * round(count/sum(count),3)) 


ggdotchart(data = adsorbate_perc, x = "adsorbate", y = "perc",
           color = "adsorbate",                                
           sorting = "descending",                       
           add = "segments",
           add.params = list(color = "lightgray", size = 2),
           rotate = TRUE,                               
           dot.size = 12,
           xlab = "Adsorbate",
           ylab = "Dataset represation (%)",
           label = adsorbate_perc$perc,                       
           font.label = list(color = "black", size = 11, 
                             vjust = 0.5),               
           ggtheme = theme(panel.grid.minor = element_blank(),
                           panel.background = element_blank(),
                           axis.text = element_text(size=16, colour = "black"),
                           axis.title = element_text(size=20, colour = "black"),
                           axis.ticks.x = element_blank(),
                           axis.text.x = element_blank(),
                           legend.position = 'none',
                           panel.border = element_rect(colour = "black", fill=NA, size=1))) 

ggsave("adsorbate_representation.pdf", height = 179, width = 179, units = "mm")


################################################################################
setwd("C:/Users/DrewX/Documents/Project-Roger-Dodger/R-ML/plots/categorical")


three_M <- zeolite_categorical %>% 
            select(m1, m2, m3) 

get_counts <- function(col){

     counts <- table(three_M[,col])  
     df <- counts %>%
           data.frame(stringsAsFactors = F) %>% 
           filter(Var1 != "")
     df$group <- col
  
     
return(df)
     
}
      
m <- lapply(colnames(three_M), get_counts) %>% bind_rows()

m$label <- gsub('\\+','^+', m$Var1)

ggdotchart(m, x = "Var1", y = "Freq",
          color = "group", 
          palette = c("#00AFBB", "#E7B800", "#FC4E07"),
          sorting = "descending", 
          add = "segments",
          rotate = TRUE,
          dot.size = 10,
          label = round(m$Freq),
          font.label = list(color = "black", size = 12,
                            vjust = 0.5),
          ggtheme =  theme(panel.grid.minor = element_blank(),
                           panel.background = element_blank(),
                           axis.text = element_text(size=16, colour = "black"),
                           axis.title = element_text(size=20, colour = "black"),
                           axis.ticks.x = element_blank(),
                           axis.text.x = element_blank(),
                           legend.position = 'none',
                           panel.border = element_rect(colour = "black", fill=NA, size=1))
          
) + labs(x = "Metal", y = "Counts")



ggsave("Metal_counts.pdf", height = 179, width = 179, units = "mm")

