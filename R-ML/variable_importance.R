library(ggsci)
library(dplyr)
library(ggpubr)
library(ggplot2)
library(ggrepel)
library(tidyverse)
library(xtable)
library(dplyr)
library(purrr)

#setwd("/home/drewx/Documents/Project-Roger-Dodger/R-ML/plots/variable_importance")
setwd("C:/Users/DrewX/Documents/Project-Roger-Dodger/R-ML/plots/variable_importance")


#(RF_var_importance <- read.table("/home/drewx/Documents/Project-Roger-Dodger/Python-ML/RFX_feature_importance.tsv", header = T, stringsAsFactors = F))
(RF_var_importance <- read.table("C:/Users/DrewX/Documents/Project-Roger-Dodger/Python-ML/RF_model_performance.tsv", header = T, stringsAsFactors = F))



top_vars <- RF_var_importance  %>% 
                 filter(importance >= 0.01)

zeolite_ref <- read.table("C:/Users/DrewX/Documents/Project-Roger-Dodger/Python-ML/zeolites database catagories V 2.txt", sep ="\t", header = T)
#zeolite_ref <- read.table("/home/drewx/Documents/Project-Roger-Dodger/Python-ML/zeolite_ref.txt", sep ="\t", header = T)

units_df <-  read.table("C:/Users/DrewX/Documents/Project-Roger-Dodger/Python-ML/zeolitesfeb10_units.txt", na.strings = "", row.names = 1, sep ="\t", stringsAsFactors = F, header = T)

Fullname <- t(units_df)

levels(zeolite_ref$Adsorbent)

zeo_cat <-  zeolite_ref %>% select_if(negate(is.numeric))
zeo_cat <- zeo_cat[colSums(!(is.na(zeo_cat))) > 0]

Adsorbent <-  levels(zeolite_ref$Adsorbent)
Adsorbate <-  levels(zeolite_ref$adsorbate )
solvent <-  levels(zeolite_ref$solvent)

get_levels <- function(colx){
  
  vx <- levels(zeolite_ref[,colx])

  return(vx[vx != ""])  
}

m1 <- get_levels("m1")
m2 <- get_levels("m2")
m3 <- get_levels("m3")

(solvent_varimp <- RF_var_importance[RF_var_importance$features %in% solvent,])
(Adsorbate_varimp <-  RF_var_importance[RF_var_importance$features %in% Adsorbate,])
(Adsorbent_varimp <- RF_var_importance[RF_var_importance$features %in% Adsorbent,])


colnames(zeolite_ref)

(zeolite_properties_varimp <-  RF_var_importance[RF_var_importance$features %in% c("SA","Vmicro","Vmeso","pore_size","Si_Al"),])
(zeolite_metals_varimp <- RF_var_importance[RF_var_importance$features %in% c(m1, m2, m3, "C1","C2","C3","x1","x2","x3","Ri1","Ri2","Ri3"),]) 
(zeolite_conditions_varimp <- RF_var_importance[RF_var_importance$features %in% c("C_0","oil_adsorbent_ratio","Temp"),])
(zeolite_adsorbate_properties_varimp  <- RF_var_importance[RF_var_importance$features %in% c("adsorbate",	"dipole_moment","chemical_hardness","kinetic_diameter"),])


zeolite_properties_varimp %>%
         arrange(desc(importance)) %>%
         mutate_at(2, round, 6)


zeolite_metals_varimp %>%
        arrange(desc(importance)) %>%
        mutate_at(2, round, 6)


zeolite_conditions_varimp %>%
       arrange(desc(importance)) %>%
       mutate_at(2, round, 6)



zeolite_properties_varimp_ALL <- rbind(Adsorbent_varimp, zeolite_properties_varimp, zeolite_metals_varimp)
zeolite_conditions_varimp_ALL <- rbind(zeolite_conditions_varimp, solvent_varimp, Adsorbate_varimp)


zeolite_properties_varimp_ALL %>%
                arrange(desc(importance)) %>%
                mutate_at(2, round, 6)

zeolite_conditions_varimp_ALL %>% 
                arrange(desc(importance)) %>%
               mutate_at(2, round, 6)
            

################################ Main ############################################################################

zeolite_properties <- data.frame(t(colSums(zeolite_properties_varimp_ALL[c(2)])), row.names = "zeolite_properties")
zeolite_conditions <- data.frame(t(colSums(zeolite_conditions_varimp_ALL[c(2)])), row.names = "zeolite_conditions")
zeolite_adsorbate_properties <- data.frame(t(colSums(zeolite_adsorbate_properties_varimp[c(2)])), row.names = "zeolite_adsorbate_properties")


zeolite_main <- rbind(zeolite_properties, zeolite_conditions, zeolite_adsorbate_properties) %>% rownames_to_column("features")

zeolite_main <- zeolite_main %>%
                arrange(desc(importance)) %>%
                mutate(perc = round(importance/sum(importance) * 100, 1)) %>%
                mutate(lab_pos = cumsum(perc) - 0.5* perc) 

zeolite_main$features <- factor(zeolite_main$features, levels = rev(as.character(zeolite_main$features)))

ggplot(zeolite_main, aes(x = 2,  y = perc,  fill = features)) +
        geom_bar(width = 1,  stat = "identity") +
        labs(x = NULL, y = NULL, fill = "Variable importance") +
        guides(fill = guide_legend(reverse = TRUE)) +
        geom_text_repel(aes(y = lab_pos,
                            label = paste(perc,"%", sep = "")),
                        min.segment.length = 0.75,
                        col = "white",
                        nudge_y = 0,
                        nudge_x = 0,
                        size = 6) + 
        theme(panel.grid.minor = element_blank(),
              panel.background = element_blank(),
              axis.title = element_text(size=20, colour = "black"),
              axis.line = element_blank(),
              axis.text = element_blank(),
              axis.ticks = element_blank(),
              legend.position = c(1.12,0.5),
              legend.title = element_text(size=18, colour = "black"),
              legend.text = element_text(size=18, colour = "black"),)+
        scale_fill_lancet(labels = c("Adsorbate properties", "Zeolite properties","Adsorption conditions")) +
        coord_polar(theta = "y") +
        xlim(0.5,3)


ggsave("main_zeolite.pdf")

######################### Zeolite properties ##################################

Adsorbent_main <- data.frame(t(colSums(Adsorbent_varimp[c(2)])), row.names = "Adsorbent")
properties_main <- data.frame(t(colSums(zeolite_properties_varimp[c(2)])),row.names = "structure")
metals_main <- data.frame(t(colSums(zeolite_metals_varimp[c(2)])), row.names = "metal_properties")

Adsorbent_main
properties_main
metals_main

(zeolite_main_prop <- rbind(Adsorbent_main, properties_main ,metals_main) %>% rownames_to_column("features"))
properties_perc = zeolite_main$perc[zeolite_main$features ==  "zeolite_properties"]

zeolite_main_prop <- zeolite_main_prop %>%
                     arrange(desc(importance)) %>%
                     mutate(perc = importance/sum(importance) * 100) %>%
                     mutate(lab_perc = round((perc/100) * properties_perc,1)) %>%
                     mutate(lab_pos = cumsum(perc) - 0.5* perc) 

zeolite_main_prop$features <- factor(zeolite_main_prop$features, levels = rev(as.character(zeolite_main_prop$features)))

ggplot(zeolite_main_prop, aes(x = 2,  y = perc,  fill = features)) +
        geom_bar(width = 1,  stat = "identity") +
        labs(x = NULL, y = NULL, fill = "Zeolite properties") +
        guides(fill = guide_legend(reverse = TRUE)) +
        geom_text_repel(aes(y = lab_pos,
                            label = paste(lab_perc,"%", sep = "")),
                        min.segment.length = 0.75,
                        col = "white",
                        nudge_y = 0.05,
                        nudge_x = 0.05,
                        size = 7) + 
        theme(panel.grid.minor = element_blank(),
              panel.background = element_blank(),
              axis.title = element_text(size=18, colour = "black"),
              axis.line = element_blank(),
              axis.text = element_blank(),
              axis.ticks = element_blank(),
              legend.position = c(1.165,0.5),
              legend.title = element_text(size=20, colour = "black"),
              legend.text = element_text(size=20, colour = "black"),)+
        coord_polar(theta = "y") +
        xlim(0.5,2.5) +
        scale_fill_nejm(labels = c("Adsorbent", "Structural framework", "Metal ion"))

ggsave("zeolite_main_prop.pdf")

##########################################################################################################
zeolite_conditions_varimp_ALL <- rbind(zeolite_conditions_varimp, solvent_varimp)

Conditions_main <- data.frame(t(colSums(zeolite_conditions_varimp[c(2)])), row.names = "Other conditions")
solvent_main <- data.frame(t(colSums(solvent_varimp[c(2)])),row.names = "Solvent")
Adsorbate_main <- data.frame(t(colSums(Adsorbate_varimp[c(2)])),row.names = "Sulphur compound")

Conditions_main
solvent_main
Adsorbent_main

zeolite_main_conditions <- rbind(Conditions_main, solvent_main, Adsorbate_main) %>% rownames_to_column("features")

conditions_perc = zeolite_main$perc[zeolite_main$features ==  "zeolite_conditions"]

zeolite_main_conditions <- zeolite_main_conditions %>%
                        arrange(desc(importance)) %>%
                        mutate(perc = importance/sum(importance) * 100) %>%
                        mutate(lab_perc = round((perc/100) * conditions_perc ,1)) %>%
                        mutate(lab_pos = cumsum(perc) - 0.5* perc) 

zeolite_main_conditions$features <- factor(zeolite_main_conditions$features, levels = rev(as.character(zeolite_main_conditions$features)))

ggplot(zeolite_main_conditions, aes(x = 2,  y = perc,  fill = features)) +
        geom_bar(width = 1,  stat = "identity") +
        labs(x = NULL, y = NULL, fill = "Adsorption conditions") +
        guides(fill = guide_legend(reverse = TRUE)) +
        geom_text_repel(aes(y = lab_pos,
                            label = paste(lab_perc,"%", sep = "")),
                        min.segment.length = 0.75,
                        col = "white",
                        nudge_y = 0,
                        nudge_x = 0,
                        size = 6) + 
        theme(panel.grid.minor = element_blank(),
              panel.background = element_blank(),
              axis.title = element_text(size=18, colour = "black"),
              axis.line = element_blank(),
              axis.text = element_blank(),
              axis.ticks = element_blank(),
              legend.position = c(1.125,0.5),
              legend.title = element_text(size=18, colour = "black"),
              legend.text = element_text(size=18, colour = "black"),)+
        scale_fill_lancet(labels = c("Other conditions", "Solvent")) +
        coord_polar(theta = "y") +
        xlim(0.5,2.5) +
       scale_fill_igv()

ggsave("zeolite_main_condi.pdf")


##########################################################################################################

struct_perc <- zeolite_main_prop$lab_perc[zeolite_main_prop$features == "structure"]

#units_df <-  read.table("/home/drewx/Documents/Project-Roger-Dodger/R-ML/zeolites_units.txt", na.strings = "", row.names = 1, sep ="\t", stringsAsFactors = F, header = T)
units_df <-  read.table("C:/Users/DrewX/Documents/Project-Roger-Dodger/Python-ML/zeolitesfeb10_names.txt", na.strings = "", row.names = 1, sep ="\t", stringsAsFactors = F, header = T)

Fullname <- t(units_df)

structx <- zeolite_properties_varimp %>%
                     arrange(desc(importance)) %>%
                     mutate(perc = importance/sum(importance) * 100) %>%
                     mutate(lab_perc = round((perc/100) * struct_perc ,1)) %>%
                     mutate(lab_pos = cumsum(perc) - 0.5* perc) %>%
                     column_to_rownames("features")

(str_framework <- merge(Fullname, structx, by = 0) %>% 
                select(Fullname,  lab_perc) %>%  
                rename(Variable=Fullname)  %>% 
                arrange(desc(lab_perc)))
                
str_framework$Variable <- factor(str_framework$Variable, levels = rev(as.character(str_framework$Variable)))

ggplot(str_framework) + 
      geom_bar(aes(y = lab_perc, x = Variable, fill = Variable), stat = "identity", width = 0.65 ) +  
      coord_flip() +
      labs(x =  "Structural framework", y = "Variable importance (%)") +
        theme(panel.grid.minor = element_blank(),
              panel.background = element_blank(),
              axis.text = element_text(size=32, colour = "black"),
              axis.title = element_text(size=32, colour = "black"),
              legend.position = "none",
              panel.border = element_rect(colour = "black", fill=NA, size=1)) +
        scale_fill_rickandmorty() +
        scale_y_continuous(limits = c(0,12), breaks =seq(0,12,2) )


ggsave("structural_framework.pdf", height = 125, width = 450, units = "mm")
############################################################################################################

ref_char <- zeolite_ref %>% 
            select_if(negate(is.numeric))

metals <- ref_char %>%  
          dplyr:: select(m1, m2, m3) 



zeolite_metals_varimp$type <- NA

metal_perc <- zeolite_main_prop$lab_perc[zeolite_main_prop$features == "metal_ion"]

zeolite_metals_varimp[zeolite_metals_varimp$features %in% ref_char$m1,]$type <- "Metal1"
zeolite_metals_varimp[zeolite_metals_varimp$features %in% ref_char$m2,]$type <- "Metal2"
zeolite_metals_varimp[zeolite_metals_varimp$features %in% ref_char$m3,]$type <- "Metal3"
zeolite_metals_varimp[zeolite_metals_varimp$features %in% c("C1","C2","C3"),]$type <- "Metal/Al"
zeolite_metals_varimp[zeolite_metals_varimp$features %in% c("x1","x2","x3"),]$type <- "Electronegativity"
zeolite_metals_varimp[zeolite_metals_varimp$features %in% c("Ri1","Ri2","Ri3"),]$type <- "Ionic radius"

(metalx <-zeolite_metals_varimp %>%
          arrange(desc(importance)) %>%
          rename(Variable=features)) 


metalx$Variable <- factor(metalx$Variable, levels = rev(as.character(metalx$Variable)))

row.names(metalx) <- metalx$Variable

Names_raw <-  read.table("C:/Users/DrewX/Documents/Project-Roger-Dodger/Python-ML/zeolitesfeb10_names.txt", na.strings = "", sep ="\t", stringsAsFactors = F, header = T)

Names <- t(Names_raw) %>% 
                data.frame(stringsAsFactors = F) %>%
                rownames_to_column(var = "Variable") %>%
                set_names("Variable","Fullname") %>%
                filter(Variable != "colname")

metalx <- merge(metalx, Names, all.x = T,  by = "Variable")

metalx[is.na(metalx$Fullname),]$Fullname <- metalx[is.na(metalx$Fullname),]$Variable  

metalx$Fullname  <- as.character(metalx$Variable)
metalx$type  <- as.character(metalx$type)
metalx[5,"Fullname"] <- " C4+"


ggbarplot(metalx, 
          x = "Fullname", 
          y = "importance",
          fill = "type",           
          color = "white",            
          palette = "gsea",            
          sort.val = "asc",         
          sort.by.groups = TRUE,     
          ylab = "Variable importance (%)",
          xlab = "Metal property",
          legend.title = "Metal property",
          rotate = TRUE) + theme(panel.grid.minor = element_blank(),
                                 panel.background = element_blank(),
                                 axis.text = element_text(size=32, colour = "black"),
                                 axis.title = element_text(size=32, colour = "black"),
                                 legend.text = element_text(size=32, colour = "black"),
                                 legend.title = element_text(size=32, colour = "black"),
                                 legend.background  = element_rect(colour = "black", fill=NA, size=1),
                                 panel.border = element_rect(colour = "black", fill=NA, size=1)) +
  scale_y_continuous(limits = c(0,0.04), breaks =seq(0,0.04,0.01))



ggsave("metal_properties.pdf", height = 220, width = 600, units = "mm")

############################################################################################################
setwd("C:/Users/DrewX/Documents/Project-Roger-Dodger/R-ML/plots/variable_importance")

cond_perc <- zeolite_main_conditions$lab_perc[zeolite_main_conditions$features == "Conditions"]

zeolite_conditions_varimp

solvent_varimp$type <-"Solvent"
Adsorbate_varimp$type <- "Sulphur compound"
zeolite_conditions_varimp$type <- "Condition"
adsorption_conditions_bind <- rbind(solvent_varimp, Adsorbate_varimp, zeolite_conditions_varimp)

(adsorption_conditionsx <- adsorption_conditions_bind %>%
                          arrange(desc(importance)) %>%
                          mutate(perc = round(importance * 100,5)) %>%
                          rename(Variable=features) %>% 
                          arrange(desc(perc)) %>%
                          filter(perc != 0) %>%
                          column_to_rownames(var ="Variable"))
  
  


(conditionx <- merge(x = adsorption_conditionsx, y = Fullname, by = 0, all.x = T))

conditionx$Fullname <- as.character(conditionx$Fullname)

conditionx[is.na(conditionx$Fullname),]$Fullname <- conditionx[is.na(conditionx$Fullname),]$Row.names

conditionx
              
ggbarplot(conditionx, 
          x = "Fullname", 
          y = "perc",
          fill = "type",           
          color = "white",            
          palette = "jco",            
          sort.val = "asc",         
          sort.by.groups = TRUE,     
          ylab = "Variable importance (%)",
          xlab = "Adsorption condition",
          legend.title = "Adsorption conditions",
          rotate = TRUE) + theme(panel.grid.minor = element_blank(),
          panel.background = element_blank(),
          axis.text = element_text(size=30, colour = "black"),
          axis.title = element_text(size=30, colour = "black"),
          legend.text = element_text(size=30, colour = "black"),
          legend.title = element_text(size=30, colour = "black"),
          legend.background  = element_rect(colour = "black", fill=NA, size=1),
          panel.border = element_rect(colour = "black", fill=NA, size=1)) +
  scale_y_continuous(limits = c(0,55), breaks =seq(0,55,5))


ggsave("process_condxn.pdf", height = 175, width = 450, units = "mm")

################################################################################

units_df <-  read.table("C:/Users/DrewX/Documents/Project-Roger-Dodger/Python-ML/zeolitesfeb10_names.txt", na.strings = "", row.names = 1, sep ="\t", stringsAsFactors = F, header = T)

Fullname <- t(units_df)

Fullname <- Fullname %>%
            data.frame %>%
            rownames_to_column(var="features")

(RF_var_importancx <- RF_var_importance %>%
                    arrange(desc(importance)) %>%
                    mutate(perc = importance * 100))
                    

RF_var_importancx <- merge(RF_var_importancx, Fullname, all = "features", all.x = T, all.y = F)

RF_var_importancx$Fullname <- as.character(RF_var_importancx$Fullname)

RF_var_importancx[is.na(RF_var_importancx$Fullname),]$Fullname <- RF_var_importancx[is.na(RF_var_importancx$Fullname),]$features.x

RF_var_importancx <- RF_var_importancx %>%
                     select(Fullname, perc) %>%
                     mutate(perc = round(perc, 4)) %>%
                     arrange(desc(perc))              

print(xtable(RF_var_importancx, digits=7, type = "latex"), file = "RF_var_importance.tex")

