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
library(caret)
library(wesanderson)



zeolite <- read.table("C:/Users/DrewX/Documents/Project-Roger-Dodger/Python-ML/zeolites database one febl14.txt", sep ="\t", header = T)

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

lapply(colnames(zeolite_numeric), plot_ggbox,  data = zeolite_numeric, units_df = units_df)



###########################Categorical variables################################
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
           dot.size = 9,
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
                           panel.border = element_rect(colour = "black", fill=NA, size=1))) +
  geom_hline(yintercept = 0, linetype = 1, color = "lightgray", size = 2)

ggsave("adsorbate_representation.pdf", height = 179, width = 179, units = "mm")


##################### Corrplot functions #######################################


zeolite_preprocess <- function(zeolite_numeric,names_df){
  
    counts <- zeolite_numeric %>% 
              summarise_all(n_distinct) %>% 
              t() %>% 
              data.frame()
    
    colnames(counts) <- "uniq_counts"
    
    uniq <- counts %>% filter(uniq_counts <= 2)
    
    drop_names <- rownames(uniq)
    
    zeolite_numeric <- zeolite_numeric %>%   
                       select(-!!drop_names)
    
    return(zeolite_numeric)

}



fix_names <- function(zeolite_numeric, names_df){
  
      drop_col <- setdiff(colnames(names_df), colnames(zeolite_numeric))
      names_df <- names_df %>% select(-!!drop_col)
      
      return(names_df)
}


get_corrmatrix <- function(data_df){

      df_Scaler <- preProcess(data_df, method = c("center", "scale"))
      scaled_data <- predict(df_Scaler, data_df)
      corr_matrix <- scaled_data %>% 
      cor %>%
      round(2)
  
      return(corr_matrix)
}


get_corrplot <- function(corr_matrix, names_df, pdf_fname, cat=F){
  
          dim(names_df)
          dim(corr_matrix)
          pvalue_matrix <- cor.mtest(corr_matrix, conf.level = .95)
          if (cat == F){
          rownames(corr_matrix) <- names_df["Fullname",]
          colnames(corr_matrix) <- names_df["Fullname",]
          }
          #open pdf graphics device for saving plot
          pdf(pdf_fname, width = 9.5)
          col <- colorRampPalette(c("#FF0000","#800080","#696969","#A9A9A9","white","#00FFFF","#00FF00", "#FFA500"))
          mag.factor <- 2
          cex.before <- par("cex")
          par(cex = 0.7)
          
          #lower triangle
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
          #hack for font sizes
          par(cex = cex.before)
          #Uppper triangle
          corrplot(corr_matrix,
                   addCoef.col = "black",
                   col = col(10),
                   tl.pos='n',
                   tl.srt = 45,
                   cl.cex = .9,
                   type = "upper", 
                   number.cex = .65,
                   method = "color",
                   add=T)
          #close graphics device
          dev.off()
          
      return(pvalue_matrix)
          
}
          
 
print_stats <- function(response_var, pvalue_matrix, corr_matrix, data_df){
  
          pvalue_df <- data.frame(pvalue_matrix$p)
          colnames(pvalue_df) <- colnames(data_df)
          rownames(pvalue_df) <- colnames(data_df)
          pvalue_df <- pvalue_df[response_var] %>% round(3)
          corr_df <- data.frame(corr_matrix)[response_var]
          merge(pvalue_df, corr_df, by = 0) %>%
          column_to_rownames("Row.names") %>%
          setNames(c("p-value", "R")) %>%
                       arrange(R)
}
          
######################## Corrplot analysis raw data ############################
          
setwd("C:/Users/DrewX/Documents/Project-Roger-Dodger/R-ML/plots/corrplot")

zeolite <- read.table("C:/Users/DrewX/Documents/Project-Roger-Dodger/Python-ML/zeolites database one febl14.txt", sep ="\t", header = T)
#No imputation, missing values filled with a zero
zeolite_numeric <- zeolite %>% 
                   select_if(is.numeric) %>% 
                   mutate_if(is.numeric , replace_na, replace = 0)
#data tables with colnames and corresponding fullnames
#rownames "colname", "Fullname"
names_df <-  read.table("C:/Users/DrewX/Documents/Project-Roger-Dodger/Python-ML/zeolitesfeb10_names.txt", row.names = 1, sep ="\t", stringsAsFactors = F, header = T)

zeolite_numeric <- zeolite_preprocess(zeolite_numeric, names_df)

names_df <- fix_names(zeolite_numeric, names_df)
corr_matrix <- get_corrmatrix(zeolite_numeric)
pvalue_matrix <-  get_corrplot(corr_matrix, names_df, "corr_matrix_raw.pdf")
print_stats("Capacity", pvalue_matrix, corr_matrix, zeolite_numeric)

########################## Imputed corrplot ####################################

zeolite_imputed <- read.table("C:/Users/DrewX/Documents/Project-Roger-Dodger/Python-ML/ZeoX_Final_encoded.tsv", sep ="\t", header = T)
ref1 <- colnames(zeolite_numeric)

zeolite_numeric_imputed  <- zeolite_imputed %>% 
                            select(!!ref1) 

corr_matrix2 <- get_corrmatrix(zeolite_numeric_imputed)
pvalue_matrix2 <-  get_corrplot(corr_matrix2, names_df, "corr_matrix_imputed.pdf")
print_stats("Capacity", pvalue_matrix2, corr_matrix2, zeolite_numeric_imputed)


####################### categorical vars corrplot  ######################################

zeolite_categorical <- zeolite_imputed %>% select(-colnames(zeolite_numeric), Capacity)
counts <- zeolite_categorical %>% summarise_all(n_distinct) %>% t() %>% data.frame()
colnames(counts) <- "uniq_counts"
uniq <- counts %>% filter(uniq_counts <= 1)
drop_names <- rownames(uniq)
zeolite_categorical <- zeolite_categorical %>%  select(-!!drop_names)


corr_matrix3 <- get_corrmatrix(zeolite_categorical)
pvalue_matrix3 <- cor.mtest(corr_matrix3, conf.level = .95)

pdf("corr_matrix2cat.pdf", width = 9.5)
col <- colorRampPalette(c("#FF0000","#800080","#696969","#A9A9A9","white","#00FFFF","#00FF00", "#FFA500"))
mag.factor <- 2
cex.before <- par("cex")
par(cex = 0.5) 

corrplot(corr_matrix3,
         p.mat = pvalue_matrix3$p,
         insig = "p-value",
         number.cex = .75,
         sig.level = -1,
         tl.pos = 'lt',
         tl.srt = 45,
         cl.pos = 'n',
         type = "lower", 
         method = "color",
         tl.col = "black",
         col = col(10),
         tl.cex = par("cex") * mag.factor, 
         cl.cex = par("cex") * mag.factor) #makes the plot 

#par(cex = cex.before)


corrplot(corr_matrix3,
         addCoef.col = "black",
         col = col(10),
         tl.pos='n',
         tl.srt = 45,
         cl.cex = .9,
         type = "upper", 
         number.cex = 1,
         method = "color",
         add=T)

dev.off()

print_stats("Capacity", pvalue_matrix3, corr_matrix3, zeolite_categorical)

######################### Multicollinearity ####################################

dt = sort(sample(nrow(zeolite_numeric_imputed), nrow(zeolite_numeric_imputed)*.7))

train_data  <- zeolite_numeric_imputed[dt,]
test_data <- zeolite_numeric_imputed[-dt,]

model1 <- lm(Capacity ~ ., data = train_data)

summary(model1)


################################################################################
