library(cluster.datasets)
library(tidyverse)
library(gridExtra)
library(factoextra)
# install.packages("factoextra")

zeolites = read.csv('zeolites_cluster.csv')

df = zeolites

#df = df [1:9]

df = na.omit(df)

# Splitting the dataset into the Training set and Test set
#install.packages('caTools')
# Install.packages(cluster)
library(factoextra)
library(cluster.datasets)
library(caTools)
set.seed(123)
fviz_nbclust(df,kmeans, method = "wss")
# Feature Scaling
df = scale(df)
head(df)
k2 = kmeans(df, centers = 3, nstart = 25)
str(k2)
print(fviz_cluster (k2, geom = "point", data = df) + ggtitle ("k = 2")) 

final = kmeans(df, 3, nstart = 25)
print(final)
fviz_cluster(final, data = df)
zeolites %>% mutate(Cluster = final$cluster) %>% group_by(Cluster) %>% summarise_all("mean")
