################################################################################################################
# Load packages
################################################################################################################
# List of required packages 
pkgs <- c(
  "dplyr",
  "ggplot2",
  "openxlsx",
  "readxl",
  "data.table",
  "lubridate",   # date and time parsing and handling
  "writexl",
  "zoo",         # time-series utilities (e.g., na.locf)
  "scales",
  "patchwork",
  "gridExtra",
  "plantecophys",
  "photosynthesis",
  "fmsb", 
  "prospectr", 
  "signal", 
  "SparseM"
)


load_pkgs <- function() {
  
  installed <- rownames(installed.packages())
  to_install <- setdiff(pkgs, installed)
  
  message("Package check:")
  message("  Installed: ", length(pkgs) - length(to_install))
  message("  To install: ", length(to_install))
  
  if (length(to_install) > 0) {
    message("Installing: ", paste(to_install, collapse = ", "))
    install.packages(
      to_install,
      dependencies = c("Depends", "Imports", "LinkingTo")
    )
  } else {
    message("All required packages are already installed.")
  }
  
  invisible(lapply(pkgs, library, character.only = TRUE))
}



################################################################################################################
# My plotting theme
################################################################################################################
library(ggplot2)
my_ACi_curve_theme <- theme(
  panel.grid.major = element_blank(),
  panel.grid.minor = element_blank(),
  panel.background = element_rect(fill = "white", colour = NA),
  axis.line = element_line(color = "black"),
  axis.text.x = element_text(angle = 0, hjust = 0.5, color = "black"),
  axis.text.y = element_text(color = "black"),
  legend.background = element_blank(),
  legend.key = element_blank(),
  legend.title = element_blank()
)


