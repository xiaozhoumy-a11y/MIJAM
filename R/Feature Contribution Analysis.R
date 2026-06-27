library(glmnet)
library(DALEX)
library(ggplot2)
library(svglite)
library(dplyr)
library(tidyr)

# Load STA code
source("/STA.txt") 

# Path settings

MODEL_PATH <- "/input.rds"

NEW_DATA_V1 <- "/TO.csv"
NEW_DATA_V2 <- "/PA.csv"

OUTPUT_ROOT <- "/DALEX"
if(!dir.exists(OUTPUT_ROOT)) dir.create(OUTPUT_ROOT, recursive = TRUE)

FILE_INDIVIDUAL_DETAIL <- file.path(OUTPUT_ROOT, "1_individual_feature_contribution_summary_all_samples.csv")
FILE_GROUP_RANKING     <- file.path(OUTPUT_ROOT, "2_feature_contribution_ranking_by_label_group.csv")
GROUP_PLOT_DIR         <- file.path(OUTPUT_ROOT, "Group_Importance_Plots_SVG")
if(!dir.exists(GROUP_PLOT_DIR)) dir.create(GROUP_PLOT_DIR)

# Read data (check.names = FALSE preserves original names)
new_v1 <- read.csv(NEW_DATA_V1, header = TRUE, stringsAsFactors = FALSE, check.names = FALSE)
new_v2 <- read.csv(NEW_DATA_V2, header = TRUE, stringsAsFactors = FALSE, check.names = FALSE)

sample_names  <- new_v1[, 2]
target_labels <- new_v1[, ncol(new_v1) - 1] 

nx1 <- as.matrix(new_v1[, 3:(ncol(new_v1) - 2)])
nx2 <- as.matrix(new_v2[, 3:(ncol(new_v2) - 2)])
nx_combined <- cbind(nx1, nx2) 

# Load model

if(!file.exists(MODEL_PATH)) stop("Model file not found!")
loaded_model <- readRDS(MODEL_PATH)
cat("Model loaded successfully.\n")

# Build explainer
y_numeric <- as.numeric(as.factor(target_labels))

custom_predict <- function(model, newdata) {
  p <- predict(model, newx = as.matrix(newdata), predtype = "link")[, "lambda.min"]
  return(as.numeric(p))
}

explainer <- DALEX:::explain.default(
  model = loaded_model,
  data = nx_combined,
  y = y_numeric,
  predict_function = custom_predict,
  label = "StaPLR_Interpretation",
  colorize = FALSE
)


# Plot the Top 15 feature contributions for each label group
cat("\nGenerating Top 15 feature contribution plots for each group, excluding the baseline and adding value labels...\n")

unique_groups <- unique(group_ranking$Group_Label)

for (g in unique_groups) {
  # Filter the current group, exclude rows with empty feature names (baseline), and then take the top 15
  plot_data <- group_ranking %>%
    filter(Group_Label == g) %>%
    filter(variable_name != "") %>% 
    head(15)
  
  # Plot
  p_group <- ggplot(plot_data, aes(x = reorder(variable_name, Mean_Contribution), y = Mean_Contribution)) +
    geom_bar(stat = "identity", aes(fill = Mean_Contribution > 0)) +
    # Add value labels: round(..., 4) keeps four decimal places, and hjust automatically adjusts the left-right offset
    geom_text(aes(label = round(Mean_Contribution, 4), 
                  hjust = ifelse(Mean_Contribution > 0, -0.15, 1.15)), 
              size = 3.5) +
    coord_flip() + 
    scale_fill_manual(values = c("TRUE" = "#00BFC4", "FALSE" = "#F8766D"), 
                      labels = c("TRUE" = "Positive", "FALSE" = "Negative")) +
    # Appropriately expand the y-axis range to prevent value labels from being clipped
    scale_y_continuous(expand = expansion(mult = c(0.2, 0.2))) + 
    labs(title = paste("Top 15 Real Features for Group:", g),
         subtitle = "Sorted by Mean Absolute Contribution",
         x = "Features", y = "Mean Contribution (Logit Score)",
         fill = "Direction") +
    theme_minimal() +
    theme(axis.text.y = element_text(size = 9, color = "black"),
          panel.grid.minor = element_blank())
  
  # Save as SVG
  safe_group_name <- gsub("[^[:alnum:]]", "_", g)
  ggsave(file.path(GROUP_PLOT_DIR, paste0("Group_", safe_group_name, "_Top15.svg")), 
         plot = p_group, device = "svg", width = 13, height = 8)
}

cat("\n==============================================\n")
cat("  Task completed!\n")
cat(paste0("  Group ranking plots, excluding the baseline and with value labels, are available at: ", GROUP_PLOT_DIR, "\n"))
cat("==============================================\n")