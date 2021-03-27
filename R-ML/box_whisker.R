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



########################## Corrplot ############################################
setwd("C:/Users/DrewX/Documents/Project-Roger-Dodger/R-ML/plots/corrplot")

names_df <-  read.table("C:/Users/DrewX/Documents/Project-Roger-Dodger/Python-ML/zeolitesfeb10_names.txt", row.names = 1, sep ="\t", stringsAsFactors = F, header = T)

names_df

counts <- zeolite_numeric %>% 
          summarise_all(n_distinct) %>% 
          t() %>% 
          data.frame()

colnames(counts) <- "uniq_counts"

uniq <- counts %>% filter(uniq_counts <= 2)

drop_names <- rownames(uniq)

zeolite_numeric <- zeolite_numeric %>%  
                   select(-!!drop_names)



set.seed(96)

Zeolite_Scaler <- preProcess(zeolite_numeric, method = c("center", "scale"))

zeolite_numeric <- predict(Zeolite_Scaler, zeolite_numeric)

corr_matrix <- zeolite_numeric  %>% 
                      mutate_if(is.numeric , replace_na, replace = 0) %>%
                      cor %>%
                      round(2)

pvalue_matrix <- cor.mtest(corr_matrix, conf.level = .95)


setdiff(colnames(names_df), colnames(zeolite_numeric))?nls


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
         cl.cex = .9,
         type = "upper", 
         number.cex = .65,
         method = "color",
         add=T)

dev.off()


pvalue_df <- data.frame(pvalue_matrix$p)

colnames(pvalue_df) <- colnames(zeolite_numeric)

rownames(pvalue_df) <- colnames(zeolite_numeric)

df_pvalue <- pvalue_df['Capacity'] %>% round(3)

corr_df <- data.frame(corr_matrix)

colnames(corr_df) <- "R" 

row.names(corr_df) <- colnames(zeolite_numeric)

df_corr <- corr_df['R'] 


df_merged <- merge(df_pvalue, df_corr, by = 0)

colnames(df_merged)[1:2] <- c("Variable", "p_value")

df_merged %>% arrange(R)



########################## Imputed corrplot ####################################

zeolite <- read.table("C:/Users/DrewX/Documents/Project-Roger-Dodger/Python-ML/zeolitesfeb10.txt", sep ="\t", header = T)

zeolite_numeric <- zeolite_encoded %>% select_if(is.numeric)

zeolite_numeric <- zeolite %>% select_if(is.numeric)

zeolite_imputed <- read.table("C:/Users/DrewX/Documents/Project-Roger-Dodger/Python-ML/ZeoImputex.tsv", sep ="\t", header = T)

zeolite_imputed <- read.table("C:/Users/DrewX/Documents/Project-Roger-Dodger/Python-ML/ZeoX_Final_encoded.tsv", sep ="\t", header = T)

ref1 <- colnames(zeolite_imputed)  
                      
names_df <-  read.table("C:/Users/DrewX/Documents/Project-Roger-Dodger/Python-ML/zeolitesfeb10_names.txt", row.names = 1, sep ="\t", stringsAsFactors = F, header = T)

order(names_df)

zeolite_numeric_imputed  <- zeolite_imputed %>% 
                            select_if(is.numeric) %>%
                            select(!!ref1)                          

names <- colnames(zeolite_numeric_imputed) 

names_df <- names_df %>%
                    select(!!names)

names_df <- names_df[,colnames(zeolite_numeric_imputed)]
  
counts <- zeolite_numeric_imputed %>% 
          summarise_all(n_distinct) %>% 
          t() %>% 
          data.frame()

colnames(counts) <- "uniq_counts"

uniq <- counts %>% filter(uniq_counts <= 1)

drop_names <- rownames(uniq)

zeolite_numeric_imputed <- zeolite_numeric_imputed %>%  select(-!!drop_names)

corr_matrix2 <- zeolite_numeric_imputed  %>% 
                mutate_if(is.numeric , replace_na, replace = 0) %>%
                cor %>%
                round(2)

pvalue_matrix <- cor.mtest(corr_matrix2, conf.level = .95)

rownames(corr_matrix2) <- names_df["Fullname",]
colnames(corr_matrix2) <- names_df["Fullname",]

pdf("corr_matrix2.pdf", width = 9.5)

col <- colorRampPalette(c("#FF0000","#800080","#696969","#A9A9A9","white","#00FFFF","#00FF00", "#FFA500"))

mag.factor <- 2
cex.before <- par("cex")
par(cex = 0.7) 

corrplot(corr_matrix2,
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


corrplot(corr_matrix2,
         addCoef.col = "black",
         col = col(10),
         tl.pos='n',
         tl.srt = 45,
         
         type = "upper", 
         number.cex = .65,
         method = "color",
         add=T)

dev.off()



######################### Multicollinearity ####################################

dt = sort(sample(nrow(zeolite_numeric_imputed), nrow(zeolite_numeric_imputed)*.7))

train_data  <- zeolite_numeric_imputed[dt,]
test_data <- zeolite_numeric_imputed[-dt,]

model1 <- lm(Capacity ~ ., data = train_data)

summary(model1)





####################### categorical vars  ######################################

zeolite <- read.table("C:/Users/DrewX/Documents/Project-Roger-Dodger/Python-ML/zeolitesfeb10.txt", sep ="\t", header = T)

zeolite_imputed <- read.table("C:/Users/DrewX/Documents/Project-Roger-Dodger/Python-ML/ZeoX_Final_encoded.tsv", sep ="\t", header = T)

zeolite_categorical <- zeolite_imputed[,!(colnames(zeolite_imputed) %in%  colnames(zeolite_numeric))]

zeolite_categorical <- cbind(zeolite_categorical, zeolite_imputed$Capacity)

colnames(zeolite_categorical)[33] <-  "Capacity"

colnames(zeolite_categorical)[]

counts <- zeolite_categorial %>% summarise_all(n_distinct) %>% t() %>% data.frame()

colnames(counts) <- "uniq_counts"

uniq <- counts %>% filter(uniq_counts <= 1)

drop_names <- rownames(uniq)

zeolite_categorical <- zeolite_categorical %>%  select(-!!drop_names)

corr_matrix2 <- zeolite_categorical  %>% 
                mutate_if(is.numeric , replace_na, replace = 0) %>%
                cor %>%
                round(2)

pvalue_matrix2 <- cor.mtest(corr_matrix2, conf.level = .95)

rownames(corr_matrix2) <- names_df["Fullname",]
colnames(corr_matrix2) <- names_df["Fullname",]

pdf("corr_matrix2cat.pdf", width = 9.5)

col <- colorRampPalette(c("#FF0000","#800080","#696969","#A9A9A9","white","#00FFFF","#00FF00", "#FFA500"))

mag.factor <- 2
cex.before <- par("cex")
par(cex = 0.5) 

corrplot(corr_matrix2,
         p.mat = pvalue_matrix2$p,
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



corrplot(corr_matrix2,
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

df_corr <-  corr_matrix2 %>% data.frame()

colnames(df_corr) <-  rownames(df_corr)

df_r <- df_corr[29] %>% arrange(desc(zeolite_imputed.Capacity))

df_pvalue <- pvalue_matrix2$p %>%  data.frame()

colnames(df_pvalue) <-  rownames(df_corr)
rownames(df_pvalue) <- colnames(df_pvalue)

df_p <- df_pvalue[29] %>% round(4) %>%  set_names("Capacity") %>% arrange(Capacity)

df_merged <- merge(df_r, df_p, by = 0)

colnames(df_merged) <- c("variable", "correlation","p_value")

category_corr <- df_merged %>% arrange(desc(correlation)) 

write.table(category_corr, "category_corr.tsv",  sep = "\t", row.names = F)
