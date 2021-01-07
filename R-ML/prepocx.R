library(magrittr)
library(dplyr)
library(tidyverse)
library(ggplot2)
library(ggpubr)

zeolite = read.table("zeolitex_final.tsv", sep = "\t", header = T)

colnames(zeolitex) %>% data.frame() 
 
zeolite <- zeolite %>% mutate_all(na_if,"") 

N <- nrow(zeolite)

missing <- zeolite %>% summarise_all(funs(100*sum(is.na(.))/N)) %>% data.frame() %>% round(2)

#Inspect missing data
t(missing)

#write to file to keep a record
write.table(missing, "zeolite.miss", sep="\t", row.names = F, quote = F)

#Adsorbetcounts
Adsorbent_analysis <-zeolite %>% group_by(Adsorbent) %>% summarise(Count=n()) %>% arrange(desc(Count))

p <- ggbarplot(Adsorbent_analysis,  x  = "Adsorbent",  y = "Count",
          fill = "Count",
          sort.by.groups = FALSE,
          sort.val = "asc")

ggpar(p, x.text.angle = 45)

Adsorbent_analysis %>% filter(Count<=2) %>%  arrange(Adsorbent) %>% data.frame()
#Singletone maybe typos
#eg Ag-Y vs AgY
#What about CsY could it be CeY

#Missing hyphens may be an issue
#Count duplicates when hyphen are removed

gsub("-", "", Adsorbent_analysis$Adsorbent) %>% 
              as.tibble() %>% 
              group_by(value) %>% 
              summarise(count=n()) %>% 
              filter(count != 1) %>%
              data.frame()

#These below need to be checked
# 1 AgY       2
# 2 CeY       2
# 3 CuY       2
# 4 HY        2
# 5 NaY       2
# 6 NiCeY     2
# 7 NiY       2

#Surface area
ggdotchart(data = zeolite %>% filter(!is.na(SA)),
           x = "Adsorbent",
           y = "SA",
           color = "Adsorbent",
           sorting = "descending",
           ggtheme = theme_pubr()) + 
           theme(legend.position = "none")


SA <- zeolite %>% select(SA) %>% filter(!is.na(SA))


ggplot(data=SA,
            aes(x = SA)) +  
            geom_density(aes(y = ..count..)) +
            geom_vline(aes(xintercept = mean(SA)), 
            linetype = "dashed", size = 0.6) + 
            ylab("Density") +
            theme_pubr()
           
  
ggviolin(data = zeolite %>% select(SA) %>% filter(!is.na(SA)),
         y = "SA",
         palette = c("#00AFBB", "#E7B800", "#FC4E07"),
         add = "boxplot")  

iqr = zeolite$SA  %>% select(SA) %>% filter(!is.na(SA))
IQR(x = )



