# Gut Microbiome Health Index and Disease Association Module Analysis

This repository contains R code for constructing a gut microbiome health index, mining disease-associated multi-view modules, and interpreting feature contributions to the health index.

The workflow integrates taxonomic and functional profiles from metagenomic data and provides three main analytical components:

1. **Health Index**
2. **Disease Association Module**
3. **Feature Contribution Analysis**

Supporting scripts are also included for model training, sparse generalized canonical correlation analysis, plotting, and utility functions.

---

## Repository Structure

```text
.
├── Health Index/
│   └── R scripts for health index construction and health/disease classification
│
├── Disease Association Module/
│   └── R scripts for identifying disease-associated multi-view modules
│
├── Feature Contribution Analysis/
│   └── R scripts for estimating feature-level contributions to the health index
│
├── STA.R or STA.txt
│   └── Core functions for StaPLR-based model fitting and prediction
│
├── sGCCA.R
│   └── Functions related to sparse generalized canonical correlation analysis
│
├── plotting.R
│   └── Plotting functions for module statistics and network visualization
│
├── utils.R
│   └── General helper functions used by the main analysis scripts
│
└── README.md
```

---

## 1. Health Index

The **Health Index** folder contains the R implementation for building a gut microbiome health index from mixed-cohort metagenomic data.

This part of the workflow is designed for binary health discrimination, where samples labeled as `Healthy` are treated as healthy controls and all other disease states are treated as disease samples.

Main functions include:

- loading taxonomic and pathway abundance profiles;
- combining multiple microbiome views;
- training a StaPLR-based health discrimination model;
- performing cross-validation;
- calculating prediction scores;
- exporting sample-level health index scores;
- saving trained models for downstream interpretation.

Typical input files include:

```text
TO.csv
PA.csv
```

where:

- `TO.csv` contains taxonomic features;
- `PA.csv` contains pathway  features;
- sample identifiers and phenotype labels should be included in the required columns according to the analysis script.

Typical outputs include:

```text
results.csv
StaPLR_fold_*.rds
```

---

## 2. Disease Association Module

The **Disease Association Module** folder contains R code for mining disease-associated modules across multiple microbiome views.

This workflow is used to identify coordinated taxonomic-functional modules associated with disease status.

Main functions include:

- loading processed multi-view microbiome data;
- cleaning feature names and generating feature-name mapping tables;
- removing zero-variance features;
- running module discovery;
- estimating module-level AUROC;
- calculating inter-view correlations;
- exporting module feature lists and edge lists;
- generating SVG network plots and module-level statistical plots.

Typical input file:

```text
input.tsv
```

Typical outputs include:

```text
Feature_Name_Mapping.csv
MintTea_Results_Final_SVG/
├── *_features.txt
├── *_edges.csv
├── *_network.svg
├── *_auc_histogram.svg
├── *_correlation_histogram.svg
└── *_ALL_MODULES_SUMMARY.csv
```

---

## 3. Feature Contribution Analysis

The **Feature Contribution Analysis** folder contains R code for interpreting the contribution of individual microbiome features to the health index.

This workflow uses DALEX-based model explanation to calculate feature-level contributions for each sample and summarize the most important features by group.

Main functions include:

- loading a trained StaPLR model;
- loading new taxonomic and pathway data;
- constructing a DALEX explainer;
- calculating sample-level feature contributions;
- summarizing group-level feature contribution rankings;
- generating SVG bar plots of top-ranked features for each group.

Typical input files include:

```text
input.rds
TO.csv
PA.csv
```

Typical outputs include:

```text
DALEX/
├── 1_individual_feature_contribution_summary_all_samples.csv
├── 2_feature_contribution_ranking_by_label_group.csv
└── Group_Importance_Plots_SVG/
    └── Group_*_Top15.svg
```

---

## Supporting Scripts

### `STA.R` or `STA.txt`

Contains core functions used for StaPLR model fitting, prediction, and health index construction.

This script is required by the Health Index and Feature Contribution Analysis workflows.

### `sGCCA.R`

Contains functions related to sparse generalized canonical correlation analysis.

This script is required by the Disease Association Module workflow.

### `plotting.R`

Contains plotting functions used to visualize module statistics, AUROC distributions, inter-view correlations, and network structures.

### `utils.R`

Contains general utility functions called by the main analysis scripts.

---

## Input Data Requirements

The scripts assume that input microbiome profiles have already been preprocessed into tabular format.

In general:

- rows represent samples;
- columns represent metadata and microbiome features;
- taxonomic features and pathway features are stored in separate files or identified by specific prefixes;
- phenotype labels should include `Healthy` for healthy controls;
- sample IDs should be consistent across taxonomic and functional files.

Before running the scripts, please check that:

1. the sample order is consistent between taxonomic and pathway files;
2. phenotype labels are correctly formatted;
3. feature columns contain numeric abundance values;
4. required supporting scripts are available in the expected paths;
5. output directories have write permission.

---

## Required R Packages

The workflows require the following R packages:

```r
glmnet
foreach
caret
DALEX
ggplot2
svglite
dplyr
tidyr
readr
mixOmics
BiocParallel
pROC
igraph
ranger
conflicted
stringr
cowplot
logger
rsample
```

Some packages are available from CRAN, while `mixOmics` and `BiocParallel` may need to be installed through Bioconductor.

Example installation:

```r
if (!requireNamespace("BiocManager", quietly = TRUE)) {
  install.packages("BiocManager")
}

BiocManager::install(c("mixOmics", "BiocParallel"), update = FALSE)

install.packages(c(
  "glmnet", "foreach", "caret", "DALEX", "ggplot2", "svglite",
  "dplyr", "tidyr", "readr", "pROC", "igraph", "ranger",
  "conflicted", "stringr", "cowplot", "logger", "rsample"
))
```

---

## General Usage

A typical analysis can be performed in the following order:

1. Run the scripts in **Health Index** to train the health discrimination model and generate health index scores.
2. Run the scripts in **Disease Association Module** to identify disease-associated taxonomic-functional modules.
3. Run the scripts in **Feature Contribution Analysis** to interpret which features contribute most to the health index.

Please update file paths in each script before running, especially paths such as:

```r
/TO.csv
/PA.csv
/input.tsv
/input.rds
/STA.txt
/utils.R
/sGCCA.R
/plotting.R
```

If running locally or on a server, these absolute paths should be changed to the correct project-specific paths.

---

## Notes

- The repository is intended for research use.
- Input data should be checked carefully before model training and interpretation.
- Cross-validation should be performed in a way that avoids information leakage.
- For multi-cohort microbiome data, study-level validation such as leave-one-study-out validation may be considered when assessing cross-study generalizability.
- Generated SVG files are vector graphics and can be edited in software such as Adobe Illustrator or Inkscape.

---
