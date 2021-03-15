library(tidyverse)
library(magrittr)
library(ggplot2)
library(ggpubr)
library(dplyr)



zeolite = read.table("zeolitex_final.tsv", sep = "\t", header = T)

colnames(zeolite) %>% data.frame() 
 
zeolite <- zeolite %>% mutate_all(na_if,"") 

##################### Multicollinearity Analysis ###############################
#http://www.sthda.com/english/articles/39-regression-model-diagnostics/160-multicollinearity-essentials-and-vif-in-r/
#A VIF value that exceeds 5 or 10 indicates a problematic amount of collinearity (James et al. 2014)
#James, Gareth, Daniela Witten, Trevor Hastie, and Robert Tibshirani. 2014. An Introduction to Statistical Learning: With Applications in R. Springer Publishing Company, Incorporated.
set.seed(1)
# [1] "Adsorbent"           "SA"                  "Vmicro"              "Vmeso"               "pore.size"          
# [6] "Si_Al"               "Ag"                  "Ce"                  "Cu"                  "Ni"                 
# [11] "Zn"                  "La"                  "Cs"                  "Pd"                  "Nd"                 
# [16] "adsorbate"           "C_start"             "solvent"             "Batch_Dynamic"       "Oil_adsorbent_ratio"
# [21] "Temp"                "Capacity" 

zeolite_subset <- zeolite %>% 
                    select(Adsorbent, Capacity) %>% #,Vmicro,Vmeso,pore.size,Si_Al,C_start,solvent,Oil_adsorbent_ratio,Temp) 
                    filter


#C_start,solvent,Oil_adsorbent_ratio,Temp,Capacity


training_samples <- zeolite_subset %>%  sample_frac(size = 0.8)

zeolite_subset$Adsorbent <- gsub('_', '-', zeolite_subset$Adsorbent)


simone1 <- lm(Adsorbent ~ Capacity, data = zeolite_subset)


summary(training_samples)
         
head(training_samples)

colnames(training_samples)

nrow(training_samples)

#training_samples %>% as_tibble() %>% View() 

test_data <- setdiff(zeolite_subset, training_samples,Vmeso)

model1 <- lm(Capacity ~ ., data = training_samples)

factor(training_samples$Adsorbent)

levels(test_data$Adsorbent)

predictions <- model1 %>% predict(test_data)


# ################################################################################
# 
# N <- nrow(zeolite)
# 
# missing <- zeolite %>% summarise_all(funs(100*sum(is.na(.))/N)) %>% data.frame() %>% round(2)
# 
# #Inspect missing data
# t(missing)
# 
# #write to file to keep a record
# write.table(missing, "zeolite.miss", sep="\t", row.names = F, quote = F)
# 
# #Adsorbetcounts
# Adsorbent_analysis <-zeolite %>% group_by(Adsorbent) %>% summarise(Count=n()) %>% arrange(desc(Count))
# 
# p <- ggbarplot(Adsorbent_analysis,  x  = "Adsorbent",  y = "Count",
#           fill = "Count",
#           sort.by.groups = FALSE,
#           sort.val = "asc")
# 
# ggpar(p, x.text.angle = 45)
# 
# Adsorbent_analysis %>% filter(Count<=2) %>%  arrange(Adsorbent) %>% data.frame()
# #Singletone maybe typos
# #eg Ag-Y vs AgY
# #What about CsY could it be CeY
# 
# #Missing hyphens may be an issue
# #Count duplicates when hyphen are removed
# 
# gsub("-", "", Adsorbent_analysis$Adsorbent) %>% 
#               as.tibble() %>% 
#               group_by(value) %>% 
#               summarise(count=n()) %>% 
#               filter(count != 1) %>%
#               data.frame()
# 
# #These below need to be checked
# # 1 AgY       2
# # 2 CeY       2
# # 3 CuY       2
# # 4 HY        2
# # 5 NaY       2
# # 6 NiCeY     2
# # 7 NiY       2
# 
# #Surface area
# ggdotchart(data = zeolite %>% filter(!is.na(SA)),
#            x = "Adsorbent",
#            y = "SA",
#            color = "Adsorbent",
#            sorting = "descending",
#            ggtheme = theme_pubr()) + 
#            theme(legend.position = "none")
# 
# 
# SA <- zeolite  %>% filter(!is.na(SA))
# 
# 
# ggplot(data=SA,
#             aes(x = SA)) +  
#             geom_density(aes(y = ..count..)) +
#             geom_vline(aes(xintercept = mean(SA)), 
#             linetype = "dashed", size = 0.6) + 
#             ylab("Density") +
#             theme_pubr()
# 
# 
#         
# 
#   
# ggviolin(data = SA,
#          y = "SA",
#          fill = "light blue",
#          palette = c("#00AFBB", "#E7B800", "#FC4E07"),
#          add = "boxplot")  
# 
# iqr <- summary(SA$SA)   
# 
# SA %>% filter(SA < 500 | SA > 700) %>% arrange(desc(SA))
# 
# 
# SA_fit <- lm(Capacity ~ SA, data = SA)
# 
# 
# summary(SA_fit)
# 
# 
# ggscatter(SA, x = "SA", 
#           y = "Capacity",
#           add = "reg.line",
#           conf.int = T) +         
#          stat_cor(label.x = 450, label.y = 60) +
#          stat_regline_equation(label.x = 450, label.y = 65)
# 
# 
# ############################ Vmicro ############################################
# 
# 
# Vmicro  <- zeolite %>% filter(!is.na(Vmicro))
# 
# 
# 
# ggviolin(data = SA,
#          y = "Vmicro",
#          fill = "light blue",
#          palette = c("#00AFBB", "#E7B800", "#FC4E07"),
#          add = "boxplot")  
# 
# 
# ggplot(Vmicro) + 
#       geom_density(aes(x = Vmicro)) + 
#                      theme_pubr()
#                      
# 
# colnames(Vmicro)
# 
# ggplot(Vmicro) +
#          geom_point(aes(x = Vmicro, y = Capacity, color = Adsorbent)) +
#          theme_pubr()
# 
# 
# 
# 
# ggscatter(SA, x = "Vmicro", 
#           y = "Capacity",
#           add = "reg.line",
#           conf.int = T) +         
#     stat_cor() +
#     stat_regline_equation(label.x = 0.35)
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
