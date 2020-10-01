library(dplyr)
library(tidyverse)
library(ggpubr)
library(corrplot)
library(ggplot2)
library(gridExtra)



zeolite <- read.table("/home/drewx/Documents/Project-Roger-Dodger/data/zeolites_review_TP.csv", sep ="\t", header = T)

colnames(zeolite)

data_cols <-c("SA", "Vmicro", "Vmeso", "pore.size", "Si_Al", "Ag", "Ce", "Cu", "C_start", "C_end", "adsorbent", "Capacity")

plots <- list()

for (i in 1:length(data_cols)){
  
  col <- data_cols[i]
  data <- data.frame(zeolite[col])
  p <- ggboxplot(data,
                 y = col,
                 xlab = "",
                 fill = col,
                 bxp.errorbar = T,
                 bxp.errorbar.width = 0.2,
                 width = 0.25,
                 palette = "jco")               
 plots[[i]] <- p
}



#setwd("/home/drewx/Documents/Project-Roger-Dodger/R-ML")
do.call(grid.arrange, c(plots, ncol = 2))
dev.off()

########################## Corrplot ################################################
library(ggcorrplot)
library(RColorBrewer)
library(GGally)
library(corrplot)
library(wesanderson)



colnames(zeolite)

corr_matrix <- zeolite  %>% 
                      mutate_if(is.numeric , replace_na, replace = 0) %>%
                      select(-c(Adsorbent, solvent, Batch_Dynamic, adsorbate, References)) %>%
                      cor_pmat() %>%
                      round(2)

pvalue_matrix <- cor.mtest(corr_matrix)



pdf("corr_matrix.pdf")

corrplot(corr_matrix,
         order="hclust", 
            tl.col="black",
              tl.cex = 1.25,
          addCoef.col = "black",
                   type = "upper",
                        diag=FALSE, 
                     method="color",
                          tl.srt = 45,
  col=rev(brewer.pal(n=8, name="RdBu")))
dev.off()



pdf("pvalue_matrix.pdf")

corrplot(corr_matrix,
         order="hclust", 
         tl.col="black",
         tl.cex = 1.25,
         type = "upper",
         p.mat = pvalue_matrix$p,
         diag=FALSE, 
         method="color",
         tl.srt = 45,
         sig.level = 0.05,
         col=rev(brewer.pal(n=8, name="RdBu")))

dev.off()



################################################################################



data_cols <-c("SA", "Vmicro", "Vmeso", "pore.size", "Si_Al", "Ag", "Ce", "Cu", "C_start", "C_end", "adsorbent", "Capacity")

plots <- list()

 


setwd("/home/drewx/Documents/Project-Roger-Dodger/R-ML/correlation")

for (i in 1:length(data_cols)){
  col <- data_cols[i]
  p <- ggscatter(zeolite, x = "Capacity" , y = col , 
            add = "reg.line", conf.int = TRUE, 
            cor.coef = TRUE, cor.method = "pearson",
            xlab = "Capicity" , ylab = col )

              
  plots[[i]] <- p
  
  pdf(paste0(col,'.pdf'))
  print(p)
  dev.off()
  
}


do.call(grid.arrange, c(plots, ncol = 2))
dev.off()



