library(magrittr)
library(dplyr)
library(tidyverse)


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
Adsorbent_analysis <-zeolite %>% group_by(Adsorbent) %>% summarise(n=n())


