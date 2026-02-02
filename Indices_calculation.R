if (!require("signal")) { install.packages("signal"); require("signal") }  ### for interp1
if (!require("SparseM")) { install.packages("SparseM"); require("SparseM") }  # for Savitzky-Golay smoothing filter
if (!require("prospectr")) { install.packages("prospectr"); require("prospectr") }  ## for resample2
if (!require("stats")) { install.packages("stats"); require("stats") }  ## for smooth.spline


setwd('/Users/luismanuelguadarramaescobar/Library/CloudStorage/OneDrive-TheUniversityofMelbourne/- PhD/Salinity and drought phenotyping/Validation Experiment/Li6800/SpectraPen(All days)')

if (!exists("new_photo_reflectance_df")) {
  # If it does not exist, read it from an RDS file
  new_photo_reflectance_df <- readRDS("new_photo_reflectance_df.rds")
  cat("new_photo_reflectance_df was loaded from RDS.\n")
} else {
  cat("new_photo_reflectance_df already exists in the environment.\n")
}



setwd('/Users/luismanuelguadarramaescobar/Library/CloudStorage/OneDrive-TheUniversityofMelbourne/- PhD/Salinity and drought phenotyping/Validation Experiment/Li6800/SpectraPen(All days)/Tomas scripts')

source('getIndices_VNIR.R')
#data=read.table('file.csv', header=T, sep=",")
data <- new_photo_reflectance_df$VIS
datarfl<-data[,c(1:dim(data)[2])]
colnames(datarfl)
noPoints <-gsub("\\RFL_", "", colnames(datarfl))
wave <- noPoints
wave<-as.numeric(wave)


for(k in c(1:dim(datarfl)[1])) {
  #print(datarfl[k][1])
  #print(datarfl[1,])
  k
  Table.indices<-getIndicesVNIR(as.numeric(datarfl[k,]),wave, header = F)
  data_for_export<-data.frame(t(Table.indices))
  temporal_file<-unique(paste('/Users/luismanuelguadarramaescobar/Library/CloudStorage/OneDrive-TheUniversityofMelbourne/- PhD/Salinity and drought phenotyping/Validation Experiment/Li6800/SpectraPen(All days)/NBHI_indices_tomas.csv',sep=""))
  if (k==1 ){
    write.table(data_for_export, file = temporal_file,sep=",", row.names = FALSE, col.names = T,append = F)
  } else {
    write.table(data_for_export, file = temporal_file,sep=",", row.names = FALSE, col.names = F,append = T)
  }
}
