library(magrittr)
library(dplyr)
library(tidyverse)


zeolite = read.table("zeolitex_final.tsv", sep = "\t", header = T)

colnames(zeolitex) %>% data.frame() 
 
zeolite <- zeolite %>% mutate_all(na_if,"") 

N <- nrow(zeolite)

zeolite %>% summarise_all(funs(sum(is.na(.)))) %>% data.frame() 



zeolite %>% summarise(n = n())


#zeolite %>% select(Adsorbent) 

#%>% summarise_all(funs(sum(is.na(.)))) 
zeolite$solvent == ""
