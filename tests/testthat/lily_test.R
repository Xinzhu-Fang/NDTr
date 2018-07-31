library(NDTr)
library(testthat)



matlab_raster_dir <- "data/raster/Zhang_Desimone_7objects_raster_data/"
raster_dir <- file.path("data/raster", "Zhang_Desimone_7objects_raster_data_rda")
create_binned_data(raster_directory_name, 'data/binned/ZD', 150, 50)

rm(list = ls())

binned.file.name <- file.path('data/binned','ZD_binned_data_150ms_bins_50ms_sampled.Rda')
specific.binned.label.name <- "stimulus_ID"    # which labels to decode
num.cv.splits <- 5   # the number of cross-validation splits

# test creating a basic DS
library(devtools)
load_all()
ds <- basic_DS$new(binned.file.name, specific.binned.label.name, num.cv.splits)
the_data <- ds$get_data()
library(dplyr)

original_order <- the_data %>% filter(siteID == 1) %>% select(labels)
shuffled_labels <- the_data %>% filter(siteID == 1) %>% select(labels) 
shuffled_labels <- sample(shuffled_labels$labels)
shuffled_labels <- data.frame(labels=rep(shuffled_labels, length(unique(the_data$siteID))))

original_order2 <- the_data %>% select(labels)
all(original_order2$labels == the_data$labels)
length(which(original_order2$labels %in% the_data$labels))
length(the_data$labels)
