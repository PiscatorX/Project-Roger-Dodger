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
Adsorbent_analysis <-zeolite %>% group_by(Adsorbent) %>% summarise(count=n())

Adsorbent_analysis %>% filter(count<=2) %>%  arrange(Adsorbent) %>% data.frame()
#Singletone maybe typos
#eg Ag-Y vs AgY
#What about CsY could it be CeY

#Missing hyphens may be an issue
#Count duplicates when hyphen are removed
gsub("-", "", Adsorbent_analysis$Adsorbent) %>% as.tibble() %>% group_by(value)  %>% summarise(count=n()) %>% filter(count != 1)
#These below need to be checked
# 1 AgY       2
# 2 CeY       2
# 3 CuY       2
# 4 HY        2
# 5 NaY       2
# 6 NiCeY     2
# 7 NiY       2

