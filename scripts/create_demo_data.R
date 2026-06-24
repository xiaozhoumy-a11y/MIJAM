# create_demo_data.R
# ------------------------------------------------------------------------------
# Generate synthetic demo data for the MIJAM workflow.
#
# This script creates three small demo files:
#   1. metadata_demo.csv
#   2. TO_demo.csv
#   3. PA_demo.csv
#
# The generated data are fully synthetic and are NOT derived from real
# metagenomic cohorts. They are intended only to demonstrate the expected input
# format and to test whether the analysis scripts can run successfully.
#
# Suggested location in repository:
#   scripts/create_demo_data.R
#
# Suggested output directory:
#   data/demo/
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

sample_id <- sprintf("DEMO_%03d", seq_len(n_samples))

health_status <- rep(c("Healthy", "Disease"), each = n_samples / 2)

study_id <- rep(
  c("DemoStudy_1", "DemoStudy_2"),
  each = n_samples / 2
)

disease_category <- ifelse(
  health_status == "Healthy",
  "Healthy",
  "Synthetic_Disease"
)

metadata <- data.frame(
  sample_id = sample_id,
  health_status = health_status,
  disease_category = disease_category,
  study_id = study_id,
  stringsAsFactors = FALSE
)

# -----------------------------
# Function to generate synthetic
# relative-abundance-like data
# -----------------------------

generate_abundance <- function(sample_id,
                               group_label,
                               n_features,
                               feature_prefix) {
  n_samples <- length(sample_id)

  # Generate sparse, positive abundance-like values
  mat <- matrix(
    rgamma(n_samples * n_features, shape = 0.5, rate = 1),
    nrow = n_samples,
    ncol = n_features
  )

  disease_idx <- which(group_label == "Disease")
  healthy_idx <- which(group_label == "Healthy")

  # Add a weak artificial signal to make the demo usable for model testing.
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

  demo_df <- data.frame(
    sample_id = sample_id,
    mat,
    check.names = FALSE
  )

  return(demo_df)
}

# -----------------------------
# Generate TO and PA demo files
# -----------------------------

TO_demo <- generate_abundance(
  sample_id = sample_id,
  group_label = health_status,
  n_features = n_to_features,
  feature_prefix = "TO_species"
)

PA_demo <- generate_abundance(
  sample_id = sample_id,
  group_label = health_status,
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

stopifnot(all(metadata$sample_id == TO_demo$sample_id))
stopifnot(all(metadata$sample_id == PA_demo$sample_id))

to_row_sums <- rowSums(TO_demo[, -1, drop = FALSE])
pa_row_sums <- rowSums(PA_demo[, -1, drop = FALSE])

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

# ------------------------------------------------------------------------------
# End of script
# ------------------------------------------------------------------------------
