# Data Dictionary

This document describes the processed data files, metadata fields, model outputs, and figure source data used in the MIJAM project.

## Project overview

MIJAM, short for Multi-view Index and Joint Association Module analysis, is a multi-view metagenomic framework for modeling gut microbiome health as a structure-function state. The analysis integrates taxonomic profiles at the species level (TO) and functional profiles at the pathway level (PA).

Raw metagenomic sequencing reads are not redistributed in this repository. Processed and de-identified feature matrices, model outputs, fold assignments, and figure source data are provided where permitted by the original data-use terms.

## Directory structure

| Directory | Description |
|---|---|
| `results/` | Model outputs, performance summaries, selected features, and module analysis results |
| `R/` | Code to reproduce the results |



## Model output files

### `results/performance_summary.csv`

This file summarizes model performance across validation settings.

| Description | Example |
|---|---|
| Model name | `MIJAM`, `GMHI`, `GMWI2`, `Early_fusion` |
| Fold identifier | `1` |
| Fold classification accuracy | `0.812` |
| Average accuracy | `0.822` |



## Feature selection results

### `results/Selected features and frequencies.csv`

This file lists the reproducibly selected features identified by models.

| Column name | Description | Example |
|---|---|---|
| `CMD-MIJAM` | Names selected by MIJAM’s feature selection on the CMD dataset | `3-HYDROXYPHENYLACETATE-DEGRADATION-PWY: 4-hydroxyphenylacetate degradation` |
| `CMD-MIJAM-frequency` | Frequency selected by MIJAM’s feature selection on the CMD dataset | `10` |
| `CMD-GMWI2` | Names selected by GMWI2’s feature selection on the CMD dataset | `s__Romboutsia_ilealis` |
| `CMD-GMWI2-frequency` | Frequency selected by GMWI2’s feature selection on the CMD dataset | `10` |
| `GMHI-MIJAM` | Names selected by MIJAM’s feature selection on the GMHI dataset | `3-HYDROXYPHENYLACETATE-DEGRADATION-PWY: 4-hydroxyphenylacetate degradation` |
| `GMHI-MIJAM-frequency` | Frequency selected by MIJAM’s feature selection on the GMHI dataset | `10` |
| `GMHI-GMWI2` | Names selected by GMWI2’s feature selection on the GMHI dataset | `s__Romboutsia_ilealis` |
| `GMHI-GMWI2-frequency` | Frequency selected by GMWI2’s feature selection on the GMHI dataset | `10` |


## sGCCA module analysis

### `results/sGCCA.csv`

This file contains species-pathway associations identified by sparse generalized canonical correlation analysis.

| Column name | Description | Example |
|---|---|---|
| `study` | Name of the research cohort | `GuptaA_2019` |
| `disease` | Disease phenotype | `CRC` |
| `disease Sample Size` | Disease Sample Size | `30` |
| `healthy sample size` | healthy sample size | `30` |
| `results` | Model parameter combinations | `keep_5//des_0.3//nrep_10//nfol_5//ncom_5//edge_0.7` |
| `module` | Module name | `module1` |
| `module_size` | Modulesize | `5` |
| `auroc` | Area under the curve | `0.796222222` |
| `mean_shuffled_auroc` | mean_shuffled_auroc | `0.775336139` |
| `sd_shuffled_auroc` | sd_shuffled_auroc | `0.061556802` |
| `inter_view_corr` | Cross-view correlation | `0.887564074` |
| `mean_shuffled_inter_view_corr` | mean_shuffled_inter_view_corr | `0.150621436` |
| `T` | Number of species | `5` |
| `P` |Number of pathways | `9` |
| `Z_Score_AUC` | Z_Score_AUC | `0.339297727` |
| `Empirical_P_value` | Empirical_P_value | `0.796222222` |
| `FDR_Adjusted_P` | FDR_Adjusted_P | `0.609341676` |
| `AUC_vs_Random_Improvement` | AUC_vs_Random_Improvement | `0.026938101` |
| `Corr_vs_Random_Diff` | Corr_vs_Random_Diff | `0.736942638` |


## Longitudinal analysis

### `results/Antibiotic interference.csv`
### `results/Dietary interference.csv`
### `results/Geographical migration.csv`

This file contains MIJAM scores for longitudinal samples.

| Column name | Description | Example |
|---|---|---|
| `Sample_Name` | De-identified sample identifier | `10-1_profile` |
| `True_Label` | True Label | `Healthy` |
| `Predicted_Class` | Predicted Label | `Baseline`, `Week_1`, `Week_4` |
| `study_context` | Longitudinal context | `Healthy` |
| `Predicted_Score` | Predicted score | `1.6646555886` |
| `Probability` | Probability | `0.840861971` |



## Data privacy and restrictions

Raw sequencing reads, individual-level clinical records, and non-de-identified metadata are not included in this repository.

The following information has been removed or generalized:

- Personal names
- Hospital identifiers
- Original clinical IDs
- Exact sampling dates
- Exact geographic locations
- Detailed clinical notes
- Any other potentially identifying information

Users should consult the original data repositories and publications for raw data access conditions.

## Notes

- `TO` indicates the taxonomic/species-level view.
- `PA` indicates the pathway/function-level view.
- `MIJAM` indicates Multi-view Index and Joint Association Module analysis.
- All processed files are intended for reproducibility of the reported analyses and should not be interpreted as raw data.
