if (!require("fmsb")) { install.packages("fmsb"); require("fmsb") }  ### VIF analysis

# Load indices 
data=read.table('/Users/luismanuelguadarramaescobar/Library/CloudStorage/OneDrive-TheUniversityofMelbourne/- PhD/Salinity and drought phenotyping/Validation Experiment/Li6800/SpectraPen(All days)/NBHI_indices_tomas.csv', header=T, sep=",")

setwd('/Users/luismanuelguadarramaescobar/Library/CloudStorage/OneDrive-TheUniversityofMelbourne/- PhD/Salinity and drought phenotyping/Validation Experiment/Li6800/SpectraPen(All days)/Tomas scripts')
source("vif_function.R")
pred_ind<-names(data[,1:dim(data)[2]]) ##
pred_ind
keep.indices.model<-vif_func(data[,pred_ind],thresh=5,trace=T)
keep.indices.model
class(keep.indices.model)
saveRDS(keep.indices.model,"/Users/luismanuelguadarramaescobar/Library/CloudStorage/OneDrive-TheUniversityofMelbourne/- PhD/Salinity and drought phenotyping/Validation Experiment/Li6800/SpectraPen(All days)/keep.indices_tomas.rds")
