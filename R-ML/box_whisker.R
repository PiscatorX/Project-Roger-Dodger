rm(list=ls())

library(dplyr)
library(tidyverse)
library(ggpubr)
library(corrplot)
library(ggplot2)
library(gridExtra)
library(ggforce)
library(units)
library(ggcorrplot)
library(RColorBrewer)
library(GGally)
library(corrplot)
library(wesanderson)




zeolite <- read.table("C:/Users/DrewX/Documents/Project-Roger-Dodger/Python-ML/zeolitesfeb10.txt", sep ="\t", header = T)

units_df <-  read.table("C:/Users/DrewX/Documents/Project-Roger-Dodger/Python-ML/zeolitesfeb10_units.txt", row.names = 1, sep ="\t", stringsAsFactors = F, header = T)

zeolite_numeric <- zeolite %>% select_if(is.numeric)

dim(zeolite_numeric)
  
zeolite_categorical <- zeolite[,!(zeolite %in% zeolite_numeric)]

install_symbolic_unit("ratio")
install_symbolic_unit("mgS")


for (col in names(zeolite_numeric)){
  
  units(zeolite_numeric[,col]) <- units_df["Units", col]
  
  print(head(zeolite_numeric[col]))
  
} 



setwd("C:/Users/DrewX/Documents/Project-Roger-Dodger/Python-ML/plots")



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

lapply(colnames(zeolite_numeric), plot_ggbox,  data = zeolite_numeric, units_df = units_df)



###########################Categorical variables################################

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
          dot.size = 9,
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
                          panel.border = element_rect(colour = "black", fill=NA, size=1))) +
         geom_hline(yintercept = 0, linetype = 1, color = "lightgray", size = 2)

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
           dot.size = 9,
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
                           panel.border = element_rect(colour = "black", fill=NA, size=1))) +
  geom_hline(yintercept = 0, linetype = 1, color = "lightgray", size = 2)

ggsave("Solvent_representation.pdf", height = 179, width = 179, units = "mm")


########################## Corrplot ############################################
names_df <-  read.table("C:/Users/DrewX/Documents/Project-Roger-Dodger/Python-ML/zeolitesfeb10_names.txt", row.names = 1, sep ="\t", stringsAsFactors = F, header = T)

names_df

colnames(zeolite_numeric)

corr_matrix <- zeolite_numeric  %>% 
                      mutate_if(is.numeric , replace_na, replace = 0) %>%
                      cor %>%
                      round(2)

pvalue_matrix <- cor.mtest(corr_matrix, conf.level = .95)


setdiff(colnames(names_df), colnames(zeolite_numeric))


rownames(corr_matrix) <- names_df["Fullname",]
colnames(corr_matrix) <- names_df["Fullname",]


pdf("corr_matrix.pdf", width = 9.5)

col <- colorRampPalette(c("#FF0000","#800080","#696969","#A9A9A9","white","#00FFFF","#00FF00", "#FFA500"))

mag.factor <- 2
cex.before <- par("cex")
par(cex = 0.7) 

corrplot(corr_matrix,
         p.mat = pvalue_matrix$p,
         insig = "p-value",
         number.cex = .9,
         sig.level = -1,
         tl.pos = 'lt',
         tl.srt = 45,
         cl.pos = 'n',
         method = "color",
         tl.col = "black",
         col = col(10),
         type = "lower", 
         tl.cex = par("cex") * mag.factor, 
         cl.cex = par("cex") * mag.factor) #makes the plot 

par(cex = cex.before)


corrplot(corr_matrix,
         addCoef.col = "black",
         col = col(10),
         tl.pos='n',
         tl.srt = 45,
         
         type = "upper", 
         number.cex = .65,
         method = "color",
         add=T)

dev.off()
#add=T
# corrplot(corr_matrix,
#          p.mat = pvalue_matrix$p,
#          type = "lower", 
#          method = "color",
#          tl.pos='lt',
#          col = col(10),
#          tl.col = "black",
#          cl.pos = "n",
#          insig = "p-value",
#          number.cex = .7,
#          sig.level = -1) 


################################################################################



data_cols <-c("SA", "Vmicro", "Vmeso", "pore.size", "Si_Al", "Ag", "Ce", "Cu", "C_start", "C_end", "adsorbent", "Capacity")

plots <- list()

 


setwd("/home/drewx/Documents/Project-Roger-Dodger/R-ML/correlation")

for (i in 1:length(data_cols)){
  col <- data_cols[i]
  p <- ggscatter(zeolite, x = "Capacity" , y = col , 
            add = "reg.line", conf.int = TRUE, 
            cor.coef = TRUE, cor.method = "pearson",
            xlab = "Capacity" , ylab = col )

              
  plots[[i]] <- p
  
  pdf(paste0(col,'.pdf'))
  print(p)
  dev.off()
  
}


do.call(grid.arrange, c(plots, ncol = 2))
dev.off()



