# create_demo_data.R
# ------------------------------------------------------------------------------
# Generate synthetic demo data for the MIJAM workflow.
#
# This script creates three small demo files:
#   1. metadata_demo.csv
#   2. TO_demo.csv
#   3. PA_demo.csv
#
# The generated TO_demo.csv and PA_demo.csv follow this format:
#   Column 1: Cohort
#   Column 2: Sample_Name
#   Middle columns: feature names
#   Penultimate column: Health_Status
#   Last column: Phenotype
#
# The generated data are fully synthetic and are NOT derived from real
# metagenomic cohorts. They are intended only to demonstrate the expected input
# format and to test whether the analysis scripts can run successfully.
# ------------------------------------------------------------------------------

set.seed(2026)

# -----------------------------
# User-adjustable parameters
# -----------------------------

out_dir <- "data/demo"

n_samples <- 40
n_to_features <- 50
n_pa_features <- 50

# -----------------------------
# Create output directory
# -----------------------------

if (!dir.exists(out_dir)) {
  dir.create(out_dir, recursive = TRUE)
}

# -----------------------------
# Generate synthetic metadata
# -----------------------------

Sample_Name <- sprintf("DEMO_%03d", seq_len(n_samples))

Cohort <- rep(
  c("DemoStudy_1", "DemoStudy_2"),
  each = n_samples / 2
)

Health_Status <- rep(
  c("Healthy", "Disease"),
  each = n_samples / 2
)

Phenotype <- ifelse(
  Health_Status == "Healthy",
  "Healthy",
  "Synthetic_Disease"
)

metadata <- data.frame(
  Cohort = Cohort,
  Sample_Name = Sample_Name,
  Health_Status = Health_Status,
  Phenotype = Phenotype,
  stringsAsFactors = FALSE
)

# -----------------------------
# Function to generate synthetic
# relative-abundance-like data
# -----------------------------

generate_abundance <- function(Sample_Name,
                               Cohort,
                               Health_Status,
                               Phenotype,
                               n_features,
                               feature_prefix) {
  n_samples <- length(Sample_Name)

  mat <- matrix(
    rgamma(n_samples * n_features, shape = 0.5, rate = 1),
    nrow = n_samples,
    ncol = n_features
  )

  disease_idx <- which(Health_Status == "Disease")
  healthy_idx <- which(Health_Status == "Healthy")

  # Features 1-5 are slightly higher in disease samples.
  if (n_features >= 5) {
    mat[disease_idx, 1:5] <- mat[disease_idx, 1:5] +
      matrix(
        rgamma(length(disease_idx) * 5, shape = 1.5, rate = 1),
        nrow = length(disease_idx),
        ncol = 5
      )
  }

  # Features 6-10 are slightly higher in healthy samples.
  if (n_features >= 10) {
    mat[healthy_idx, 6:10] <- mat[healthy_idx, 6:10] +
      matrix(
        rgamma(length(healthy_idx) * 5, shape = 1.5, rate = 1),
        nrow = length(healthy_idx),
        ncol = 5
      )
  }

  # Convert each sample to relative abundance
  mat <- mat / rowSums(mat)

  colnames(mat) <- sprintf("%s_%03d", feature_prefix, seq_len(n_features))

  feature_df <- as.data.frame(mat, check.names = FALSE)

  demo_df <- data.frame(
    Cohort = Cohort,
    Sample_Name = Sample_Name,
    feature_df,
    Health_Status = Health_Status,
    Phenotype = Phenotype,
    check.names = FALSE,
    stringsAsFactors = FALSE
  )

  return(demo_df)
}

# -----------------------------
# Generate TO and PA demo files
# -----------------------------

TO_demo <- generate_abundance(
  Sample_Name = Sample_Name,
  Cohort = Cohort,
  Health_Status = Health_Status,
  Phenotype = Phenotype,
  n_features = n_to_features,
  feature_prefix = "TO_species"
)

PA_demo <- generate_abundance(
  Sample_Name = Sample_Name,
  Cohort = Cohort,
  Health_Status = Health_Status,
  Phenotype = Phenotype,
  n_features = n_pa_features,
  feature_prefix = "PA_pathway"
)

# -----------------------------
# Export demo files
# -----------------------------

metadata_path <- file.path(out_dir, "metadata_demo.csv")
to_path <- file.path(out_dir, "TO_demo.csv")
pa_path <- file.path(out_dir, "PA_demo.csv")

write.csv(metadata, metadata_path, row.names = FALSE)
write.csv(TO_demo, to_path, row.names = FALSE)
write.csv(PA_demo, pa_path, row.names = FALSE)

# -----------------------------
# Basic checks
# -----------------------------

stopifnot(all(metadata$Cohort == TO_demo$Cohort))
stopifnot(all(metadata$Cohort == PA_demo$Cohort))

stopifnot(all(metadata$Sample_Name == TO_demo$Sample_Name))
stopifnot(all(metadata$Sample_Name == PA_demo$Sample_Name))

stopifnot(all(metadata$Health_Status == TO_demo$Health_Status))
stopifnot(all(metadata$Health_Status == PA_demo$Health_Status))

stopifnot(all(metadata$Phenotype == TO_demo$Phenotype))
stopifnot(all(metadata$Phenotype == PA_demo$Phenotype))

# Feature columns are from the 3rd column to the 3rd-from-last column
to_feature_cols <- 3:(ncol(TO_demo) - 2)
pa_feature_cols <- 3:(ncol(PA_demo) - 2)

to_row_sums <- rowSums(TO_demo[, to_feature_cols, drop = FALSE])
pa_row_sums <- rowSums(PA_demo[, pa_feature_cols, drop = FALSE])

if (any(abs(to_row_sums - 1) > 1e-8)) {
  warning("Some TO rows do not sum to 1.")
}

if (any(abs(pa_row_sums - 1) > 1e-8)) {
  warning("Some PA rows do not sum to 1.")
}

message("Synthetic demo data created successfully.")
message("Output directory: ", out_dir)
message("Files:")
message("  - ", metadata_path)
message("  - ", to_path)
message("  - ", pa_path)
message("")
message("TO_demo.csv and PA_demo.csv format:")
message("  Column 1: Cohort")
message("  Column 2: Sample_Name")
message("  Middle columns: features")
message("  Penultimate column: Health_Status")
message("  Last column: Phenotype")

# ------------------------------------------------------------------------------
# End of script
# ------------------------------------------------------------------------------
