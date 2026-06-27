# MIJAM: Multi-view Index and Joint Association Module Analysis for Gut Microbiome Health

This repository contains the R code, processed result files, and documentation for **MIJAM** (**Multi-view Index and Joint Association Module analysis**), a multi-view metagenomic framework for modeling gut microbiome health as a structure-function state.

MIJAM integrates taxonomic profiles at the species level (**TO**) and functional profiles at the pathway level (**PA**) to construct an interpretable gut microbiome health index, compare baseline models, identify reproducibly selected features, mine disease-associated multi-view modules, and evaluate microbiome health-state changes in longitudinal perturbation datasets.

---

## Overview

The repository supports three major analytical components:

1. **Health Index**  
   Construction of a gut microbiome health index using multi-view species and pathway profiles.

2. **Disease Association Module**  
   Identification of disease-associated species-pathway modules using sparse generalized canonical correlation analysis (sGCCA).

3. **Feature Contribution Analysis**  
   Interpretation of feature-level contributions to the microbiome health index using model explanation methods.

The workflow is designed for research use and reproducible analysis of processed metagenomic abundance profiles.

---

## Repository structure

```text
.
├── R/
│   ├── Health Index/
│   │   └── R scripts for health index construction and health/disease classification
│   │
│   ├── Disease Association Module/
│   │   └── R scripts for identifying disease-associated multi-view modules
│   │
│   ├── Feature Contribution Analysis/
│   │   └── R scripts for estimating feature-level contributions to the health index
│   │
│   ├── sGCCA.R
│   │   └── Functions related to sparse generalized canonical correlation analysis
│   │
│   ├── plotting.R
│   │   └── Plotting functions for module statistics and network visualization
│   │
│   └── utils.R
│       └── General helper functions used by the main analysis scripts
│
├── results/
│   ├── performance_summary.csv
│   ├── Selected features and frequencies.csv
│   ├── sGCCA.csv
│
├── data_dictionary.md
│
│
├── LICENSE
└── README.md
```

---

## 1. Health Index

The **Health Index** module implements the construction of a gut microbiome health index from mixed-cohort metagenomic data.

This workflow treats samples labeled as `Healthy` as healthy controls and other disease states as disease samples for binary health-state discrimination.

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

- `TO.csv` contains taxonomic or species-level features;
- `PA.csv` contains pathway-level functional features;
- sample identifiers and phenotype labels should be formatted according to the corresponding analysis script.

Typical outputs include:

```text
results.csv
StaPLR_fold_*.rds
```

---

## 2. Disease Association Module

The **Disease Association Module** implements disease-associated module discovery across multiple microbiome views.

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

The **Feature Contribution Analysis** module interprets the contribution of individual microbiome features to the health index.

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

## Result files

The `results/` directory contains processed model outputs and summary tables used for downstream analysis and figure generation.

### `results/performance_summary.csv`

This file summarizes model performance across validation settings.

It includes information such as:

- model name;
- fold identifier;
- fold-level classification accuracy;
- average accuracy.

Example models include:

```text
MIJAM
GMHI
GMWI2
Early_fusion
```

### `results/Selected features and frequencies.csv`

This file lists reproducibly selected features identified by different models and datasets.

Main columns include:

| Column | Description |
|---|---|
| `CMD-MIJAM` | Features selected by MIJAM on the CMD dataset |
| `CMD-MIJAM-frequency` | Selection frequency of MIJAM-selected features on the CMD dataset |
| `CMD-GMWI2` | Features selected by GMWI2 on the CMD dataset |
| `CMD-GMWI2-frequency` | Selection frequency of GMWI2-selected features on the CMD dataset |
| `GMHI-MIJAM` | Features selected by MIJAM on the GMHI dataset |
| `GMHI-MIJAM-frequency` | Selection frequency of MIJAM-selected features on the GMHI dataset |
| `GMHI-GMWI2` | Features selected by GMWI2 on the GMHI dataset |
| `GMHI-GMWI2-frequency` | Selection frequency of GMWI2-selected features on the GMHI dataset |

### `results/sGCCA.csv`

This file contains species-pathway associations and module-level statistics identified by sparse generalized canonical correlation analysis.

Main columns include:

| Column | Description |
|---|---|
| `study` | Name of the research cohort |
| `disease` | Disease phenotype |
| `disease Sample Size` | Number of disease samples |
| `healthy sample size` | Number of healthy samples |
| `results` | Model parameter combination |
| `module` | Module name |
| `module_size` | Number of features in the module |
| `auroc` | Area under the ROC curve |
| `mean_shuffled_auroc` | Mean AUROC of shuffled modules |
| `sd_shuffled_auroc` | Standard deviation of shuffled AUROC |
| `inter_view_corr` | Cross-view correlation |
| `mean_shuffled_inter_view_corr` | Mean shuffled cross-view correlation |
| `T` | Number of species features |
| `P` | Number of pathway features |
| `Z_Score_AUC` | Z score of AUROC compared with shuffled modules |
| `Empirical_P_value` | Empirical p value |
| `FDR_Adjusted_P` | FDR-adjusted p value |
| `AUC_vs_Random_Improvement` | AUROC improvement over random modules |
| `Corr_vs_Random_Diff` | Cross-view correlation difference compared with random modules |


The following files contain MIJAM scores for longitudinal microbiome perturbation datasets:

```text
results/Antibiotic interference.csv
results/Dietary interference.csv
results/Geographical migration.csv
```

Main columns include:

| Column | Description |
|---|---|
| `Sample_Name` | De-identified sample identifier |
| `True_Label` | True sample label |
| `Predicted_Class` | Predicted class |
| `study_context` | Longitudinal context |
| `Predicted_Score` | Predicted MIJAM score |
| `Probability` | Prediction probability |

These files can be used to evaluate changes in microbiome health-state scores under antibiotic exposure, dietary perturbation, and geographic migration.

---

## Input data requirements

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

## Required R packages

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

## General usage

A typical analysis can be performed in the following order:

1. Run the scripts in **Health Index** to train the health discrimination model and generate health index scores.
2. Run the scripts in **Disease Association Module** to identify disease-associated taxonomic-functional modules.
3. Run the scripts in **Feature Contribution Analysis** to interpret which features contribute most to the health index.
4. Use the processed result files in `results/` to reproduce summary statistics and figures.

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

If running locally or on a server, these absolute paths should be changed to project-specific paths.

---

## Reproducibility notes

To improve reproducibility:

- keep fold assignments fixed when reproducing cross-validation results;
- set random seeds before model training and feature selection;
- generate all figures from saved result tables or figure source data;
- record R package versions using `sessionInfo()` or `renv`.

Recommended documentation files include:

```text
docs/data_dictionary.md
docs/workflow.md
sessionInfo.txt
renv.lock
```

---

## Data privacy and restrictions

Raw sequencing reads, individual-level clinical records, and non-de-identified metadata are not included in this repository.

The following information should not be uploaded to this repository:

- personal names;
- hospital identifiers;
- original clinical IDs;
- exact sampling dates;
- exact geographic locations;
- detailed clinical notes;
- raw FASTQ, BAM, or SAM files;
- API keys, access tokens, or local absolute paths.

Users should consult the original data repositories and publications for raw data access conditions.

---

## Notes

- `TO` indicates the taxonomic or species-level view.
- `PA` indicates the pathway or functional view.
- `MIJAM` indicates Multi-view Index and Joint Association Module analysis.
- `sGCCA` indicates sparse generalized canonical correlation analysis.
- Generated SVG files are vector graphics and can be edited in software such as Adobe Illustrator or Inkscape.
- All processed files are intended for reproducibility of the reported analyses and should not be interpreted as raw sequencing data.

---

## License

The code in this repository is released under the MIT License unless otherwise specified.

Processed data and result files may be subject to the terms of the original data sources and should be used only where permitted by the original data-use agreements.

---