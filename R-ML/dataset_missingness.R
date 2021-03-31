library(units)
library(dplyr)


missingness  <- read.table("ZeoX_Final_encoded.miss", header = T) 

units_df <-  read.table("C:/Users/DrewX/Documents/Project-Roger-Dodger/Python-ML/zeolites_units.txt", na.strings = "", row.names = 1, sep ="\t", stringsAsFactors = F, header = T)

install_symbolic_unit("ratio")
install_symbolic_unit("mgS")


for (col in names(zeolite_numeric)){
  
  units(zeolite_numeric[,col]) <- units_df["Units", col]
  
} 

full_names  <- t(units_df) 

full_names

row.names(missingness) <- missingness$Feature

missingness  <- missingness %>%
                arrange(desc(Missingness)) %>%
                data.frame()

missingness$type<- NA
properties <- c("Adsorbent","SA", "Vmicro","Vmeso","pore_size","Si_Al")
metal_ions <- c("Na","Ag","Ce","Cu","Ni","Zn","Fe2","La","Cs","Pd","Nd")
conditions <- c("adsorbate","C_0", "solvent", "oil_adsorbent_ratio", "Temp","Capacity")

missingness[rownames(missingness) %in% properties,]$type <- "Zeolite properties"
missingness[rownames(missingness) %in% metal_ions,]$type <- "Metal ion"
missingness[rownames(missingness) %in% conditions,]$type <- "Adsorption conditions"

missing_data <- merge(missingness, full_names, by = 0, all = T) %>% 
               column_to_rownames("Row.names")


#&& Missingness != 100
missing_data <- missing_data %>% 
                drop_na(Fullname) %>%
                filter(Missingness != 0 | Missingness == 100)


ggbarplot(missing_data, x = "Fullname", y = "Missingness",
          fill = "type",               
          color = "white",            
          palette = "jco",            
          sort.val = "asc", 
          rotate = TRUE, 
          sort.by.groups = TRUE,     
          x.text.angle = 90           
)

