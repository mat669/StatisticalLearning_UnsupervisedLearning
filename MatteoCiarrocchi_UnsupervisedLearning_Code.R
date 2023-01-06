library(haven)
library(plot3D)
library(readxl)
final_dataset <- read_excel("C:\\Users\\Utente\\OneDrive\\Desktop\\SL exam\\unsupervised_dataset.xlsx")
unsupervised_dataset <- final_dataset
unsupervised_dataset <- unsupervised_dataset[,-c(1)]
rownames(unsupervised_dataset) <- final_dataset$Territorio
rho <- cor(unsupervised_dataset)
eigen(rho) ### eigenvalues and eigenvactors

### Variance and cumulative variance
autoval <- eigen(rho)$values
autovec <- eigen(rho)$vectors
pvarsp = autoval/p
pvarspcum = cumsum(pvarsp)
tab<-round(cbind(autoval,pvarsp*100,pvarspcum*100),3)
colnames(tab)<-c("eigenval","%var","%cumvar")
tab

### Scree diagram
plot(autoval, type="b", main="Scree Diagram", xlab="Components", ylab="Eigenvalue")
abline(h=1, lwd=3, col="red")

### Componnets and communality
comp<-round(cbind(
  -eigen(rho)$vectors[,1]*sqrt(autoval[1]),
  -eigen(rho)$vectors[,2]*sqrt(autoval[2]),
  -eigen(rho)$vectors[,3]*sqrt(autoval[3])
),4)
rownames(comp)<-colnames(unsupervised_dataset)
colnames(comp)<-c("comp1","comp2","comp3")
communality<-comp[,1]^2+comp[,2]^2+comp[,3]^2 
comp<-cbind(comp,communality)
comp

#### 3D graphical representation of loadings
scatter3D(comp[,1], comp[,2], comp[,3],
          xlab = "comp1", ylab = "comp2", zlab = "comp3",
          main = "Loading plot - 3 components",
          bty = "g", ticktype = "detailed", d = 2,
          theta = 60, phi = 20, col = 'blue',
          pch = 19, cex = 0.8)
text3D(comp[,1],comp[,2],comp[,3],labels = rownames(comp),add = TRUE,
       cex = 0.5,
       adj = 0.5, font = 1)

#### 3D score plot
score <- unsupervised.scale%*%autovec[,1:3]

#score plot
scorez<-round(cbind
              (-score[,1]/sqrt(autoval[1]),
                score[,2]/sqrt(autoval[2]),
                score[,3]/sqrt(autoval[3])),2)
x <- scorez[,1]
y <- scorez[,2]
z <- scorez[,3]
#plots
scatter3D(x, y, z,
          xlab = "comp1", ylab = "comp2", zlab = "comp3",
          main = "Scores plot - 3 components",
          bty = "g", ticktype = "detailed", d = 2,
          theta = 60, phi = 20, col = 'blue',
          pch = 19, cex = 0.8)
text3D(x,y,z,labels = rownames(unsupervised_dataset),add = TRUE,
       cex = 0.5,
       adj = 0.5, font = 1)


############################### Clustering

### Dendrograms of the three methods
scaled <- dist(scale(unsupervised_dataset))
opar <- par(mfrow =  c(1,3) )                 
h1<-hclust(scaled, method="average")
plot(h1, main="average linkage")
h2<-hclust(scaled, method="complete")
plot(h2, main="complete linkage")
h3<-hclust(scaled, method="ward.D2")
plot(h3, main="Ward linkage")

####compute and plot wss ---> elbow method
wss <- sapply(1:14,
              function(k){kmeans(scaled, k, nstart=21,iter.max = 14 )$tot.withinss})
wss
plot(1:14, wss,
     type="b", pch = 19, frame = FALSE,
     xlab="Number of clusters K",
     ylab="Total within-clusters sum of squares")

### Table-comparisons
cut_av <- cutree(h1, k = 3)
cut_compl <- cutree(h2, k = 3)
cut_ward <- cutree(h3, k = 3)

#Confront the different clustering methods
table(cut_av,cut_compl)
table(cut_av,cut_ward)
table(cut_compl,cut_ward)

#### Clusters using Ward method
cut_ward <- cutree(h3, k = 3)
cut_ward

###### Variables in relation with clusters
medie_ward_scaled<-aggregate(scale(unsupervised_dataset), list(cut_ward), mean)
medie_ward_scaled