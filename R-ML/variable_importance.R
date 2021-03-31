library(ggsci)
library(dplyr)
library(ggplot2)
library(ggrepel)
library(tidyverse)


setwd("/home/drewx/Documents/Project-Roger-Dodger/R-ML/plots/variable_importance")

(RF_var_importance <- read.table("/home/drewx/Documents/Project-Roger-Dodger/Python-ML/RFX_feature_importance.tsv", header = T, stringsAsFactors = F))

top_vars <- RF_var_importance  %>% 
                 filter(importance >= 0.01)

#zeolite_ref <- read.table("C:/Users/DrewX/Documents/Project-Roger-Dodger/Python-ML/zeolite_ref.txt", sep ="\t", header = T)

zeolite_ref <- read.table("/home/drewx/Documents/Project-Roger-Dodger/Python-ML/zeolite_ref.txt", sep ="\t", header = T)

levels(zeolite_ref$Adsorbent)

zeo_cat <-  zeolite_ref %>% select_if(negate(is.numeric))
zeo_cat <- zeo_cat[colSums(!(is.na(zeo_cat))) > 0]

Adsorbent <-  levels(zeolite_ref$Adsorbent)
Adsorbate <-  levels(zeolite_ref$S)
solvent <-  levels(zeolite_ref$solvent)

(solvent_varimp <- RF_var_importance[RF_var_importance$features %in% solvent,])
(Adsorbate_varimp <-  RF_var_importance[RF_var_importance$features %in% Adsorbate,])
(Adsorbent_varimp <- RF_var_importance[RF_var_importance$features %in% Adsorbent,])


(zeolite_properties_varimp <-  RF_var_importance[RF_var_importance$features %in% c("SA","Vmicro","Vmeso","pore_size","Si_Al"),])
(zeolite_metals_varimp <- RF_var_importance[RF_var_importance$features %in% c("Na","Ag","Ce","Cu","Ni","Zn","Cs"),]) 
(zeolite_conditions_varimp <- RF_var_importance[RF_var_importance$features %in% c("C_0","oil_adsorbent_ratio","Temp"),])

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

zeolite_main <- rbind(zeolite_properties, zeolite_conditions) %>% rownames_to_column("features")

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
        scale_fill_lancet(labels = c("Process conditions", "Zeolite properties")) +
        coord_polar(theta = "y") +
        xlim(0.5,3)


ggsave("main_zeolite.pdf")

######################### Zeolite properties ##################################

Adsorbent_main <- data.frame(t(colSums(Adsorbent_varimp[c(2)])), row.names = "Adsorbent")
properties_main <- data.frame(t(colSums(zeolite_properties_varimp[c(2)])),row.names = "structure")
metals_main <- data.frame(t(colSums(zeolite_metals_varimp[c(2)])), row.names = "metal_ion")

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
                        nudge_y = 0,
                        nudge_x = 0,
                        size = 6) + 
        theme(panel.grid.minor = element_blank(),
              panel.background = element_blank(),
              axis.title = element_text(size=18, colour = "black"),
              axis.line = element_blank(),
              axis.text = element_blank(),
              axis.ticks = element_blank(),
              legend.position = c(1.25,0.5),
              legend.title = element_text(size=20, colour = "black"),
              legend.text = element_text(size=18, colour = "black"),)+
        coord_polar(theta = "y") +
        xlim(0.5,2.5) +
        scale_fill_nejm(labels = c("Adsorbent", "Structural framework", "Metal ion"))

ggsave("zeolite_main_prop.pdf")

##########################################################################################################
zeolite_conditions_varimp_ALL <- rbind(zeolite_conditions_varimp, solvent_varimp)

Conditions_main <- data.frame(t(colSums(zeolite_conditions_varimp[c(2)])), row.names = "Conditions")
solvent_main <- data.frame(t(colSums(solvent_varimp[c(2)])),row.names = "Solvent")
Adsorbate_main <- data.frame(t(colSums(Adsorbate_varimp[c(2)])),row.names = "Adsorbate")

Adsorbent_main
Conditions_main
solvent_main

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
              legend.position = c(1.2,0.5),
              legend.title = element_text(size=18, colour = "black"),
              legend.text = element_text(size=18, colour = "black"),)+
        scale_fill_lancet(labels = c("Other conditions", "Solvent")) +
        coord_polar(theta = "y") +
        xlim(0.5,2.5) +
       scale_fill_igv()

ggsave("zeolite_main_condi.pdf")
##########################################################################################################
properties_main_perc = zeolite_main_prop$perc[zeolite_main_prop$features ==  "zeolite_properties"]


zeolite_properties_varimp %>%
          arrange(desc(importance)) %>%
          mutate(perc = importance/sum(importance) * 100) %>%
          mutate(lab_perc = round((perc/100) * properties_perc ,1)) %>%
          mutate(lab_pos = cumsum(perc) - 0.5* perc)





# RF <- RF_var_importance   %>%
#           arrange(desc(importance)) %>%
#           mutate(perc = importance/sum(importance) * 100) %>%
#           mutate(lab_perc = round((perc/100) * conditions_perc ,1)) %>%
#           mutate(lab_pos = cumsum(perc) - 0.5* perc) 
# 
# 
# 

# zeolite_properties_main <- zeolite_properties_varimp %>%
#                            arrange(desc(importance_mean)) %>%
#                            mutate(perc = importance_mean/sum(importance_mean) * 100) %>%
#                            mutate(lab_pos = cumsum(perc) - 0.5* perc) 
# 
# zeolite_properties_varimp  <- zeolite_properties_varimp  %>%
#                               arrange(desc(importance_mean)) %>%
#                               mutate(perc = importance_mean/sum(importance_mean) * 100) %>%
#                               mutate(lab_perc = round((perc/100) * properties_perc,1)) %>%
#                               mutate(lab_pos = cumsum(perc) - 0.5* perc) 
# 
# 
# 
# zeolite_main_conditions$features <- factor(zeolite_main_conditions$features, levels = rev(as.character(zeolite_main_conditions$features)))
# 
# zeolite_properties_main$features <- factor(zeolite_properties_main$features, levels = rev(as.character(zeolite_properties_main$features)))
# 
# properties_perc = zeolite_main$perc[zeolite_main$features ==  "zeolite_properties"]
# 
# properties_perc
# 
# zeolite_main_prop
# 
# zeolite_main_prop <- zeolite_main_prop %>%
#   arrange(desc(importance_mean)) %>%
#   mutate(perc = importance_mean/sum(importance_mean) * 100) %>%
#   mutate(lab_perc = round((perc/100) * properties_perc,1)) %>%
#   mutate(lab_pos = cumsum(perc) - 0.5* perc) 





#########################################################################################################





# ggplot(top_vars, aes(x = 2,  y = perc,  fill = features)) +
#    geom_bar(width = 1,  stat = "identity") +
#    labs(x = NULL, y = NULL, fill = NULL) +
#   theme(panel.grid.minor = element_blank(),
#         panel.background = element_blank(),
#         axis.text = element_text(size=20, colour = "black"),
#         axis.title = element_text(size=20, colour = "black"))+
#    guides(fill = guide_legend(reverse = TRUE)) +
#    geom_text_repel(aes(y = lab_pos,
#                  label = paste(lab_perc,"%", sep = "")),
#                  min.segment.length = 0.75,
#                  col = "white",
#                  nudge_y = 0,
#                  nudge_x = 0,
#                  size = 6) +
#    theme(axis.line = element_blank(),
#         legend.text = element_text(size=20, colour = "black"),
#         axis.text = element_blank(),
#         axis.ticks = element_blank()) +  
#    scale_fill_lancet() +
#   coord_polar(theta = "y") +
#   xlim(0.5,2.5)
#    
# 
#https://stackoverflow.com/questions/47752037/pie-chart-with-ggplot2-with-specific-order-and-percentage-annotations/47752576