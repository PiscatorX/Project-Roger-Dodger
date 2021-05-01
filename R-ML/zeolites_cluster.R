library(cluster.datasets)
library(tidyverse)
library(gridExtra)
library(factoextra)
library(caTools)
library(dplyr)
library(ggplot2)
library(ggfortify)
set.seed(123)


zeolites = read.csv('zeolites_cluster.csv')

#check column names 
colnames(zeolites)

#select columns of interest
df = zeolites[,c("cm3.g", "PC")]


#check new dataframe
head(df)


#df = df [1:9]


zeolites_label <- read.table("zeolites database catagories V 2.txt", sep = "\t", header = T, strip.white = T)

ref_numeric <- zeolites_label %>% select_if(is.numeric)

scaled_df <- scale(zeolite_df)

dim(zeolites_df)

dim(zeolites_label)

pca_res <- prcomp(zeolites_df, scale. = TRUE)

ggplot2::autoplot(pca_res, data = ref_numeric, colour = 'Adsorbent')

clusters <- hclust(dist(zeolites_df$Capacity))

plot(clusters)

fviz_nbclust(zeolites_df, kmeans, method = "wss")

df <- zeolites_df %>%
      data.frame()

k2 = kmeans(df, centers = 3, nstart = 25)

str(k2)

k2$cluster

print(fviz_cluster (k2, geom = "point", data = df) + ggtitle ("k = 2")) 

final = kmeans(df, 3, nstart = 25)
print(final)
fviz_cluster(final, data = df)
zeolites %>% 
  mutate(Cluster = final$cluster) %>% 
  group_by(Cluster) %>% 
  summarise_all("mean")




