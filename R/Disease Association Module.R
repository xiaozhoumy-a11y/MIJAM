# --- Install and load required packages ---
if (!requireNamespace("BiocManager", quietly = TRUE)) {
  install.packages("BiocManager")
}
if (!requireNamespace("mixOmics", quietly = TRUE)) {
  BiocManager::install(c("mixOmics", "BiocParallel"), update = FALSE)
}

# High-quality SVG export
required_packages <- c("logger", "dplyr", "rsample", "pROC", "igraph", "ranger", 
                       "conflicted", "stringr", "cowplot", "ggplot2", "readr", "caret", "svglite")
new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) install.packages(new_packages)

library(mixOmics)
library(readr)
library(caret)
library(dplyr)
library(ggplot2)
library(igraph)
library(stringr)
library(svglite) 

cat("All required packages have been loaded.\n")

# --- Load functions and data ---

source("/utils.R")
source("/sGCCA.R")
source("/plotting.R")

# Load data
test_data_filepath <- "/input.tsv"
if (!file.exists(test_data_filepath)) {
  stop(paste("File not found:", test_data_filepath))
}

test_data <- read_delim(test_data_filepath, delim = "\t", show_col_types = FALSE)
cat("Test data loaded successfully.\n")

# Confirm key columns
target_group_col <- "DiseaseState"
target_id_col <- "sample_id"

if (!all(c(target_group_col, target_id_col) %in% colnames(test_data))) {
  stop(" error: The data is missing the 'DiseaseState' or 'sample_id' column.")
}

# --- Key step: clean column names and construct mapping table ---
cat("\nCleaning column names and creating the mapping table...\n")
original_names <- colnames(test_data)
new_names <- make.names(original_names) 

clean_group_col <- new_names[match(target_group_col, original_names)]
clean_id_col <- new_names[match(target_id_col, original_names)]

name_mapping <- data.frame(
  Original = original_names,
  Clean = new_names,
  stringsAsFactors = FALSE
)
write.csv(name_mapping, "Feature_Name_Mapping.csv", row.names = FALSE)
colnames(test_data) <- new_names


