library(glmnet)
library(foreach)
library(caret)

OUTPUT_CSV_PATH <- "/results.csv"


# Load the STA function
source("/STA.txt")

# Reading and pre-processing data
view1_data <- read.csv("/TO.csv", header = TRUE, stringsAsFactors = FALSE)
view2_data <- read.csv("/PA.csv", header = TRUE, stringsAsFactors = FALSE)


sample_names <- view1_data[, 2]

x1 <- as.matrix(view1_data[, 3:(ncol(view1_data) - 2)])
x2 <- as.matrix(view2_data[, 3:(ncol(view2_data) - 2)])
x <- cbind(x1, x2)
view <- c(rep(1, ncol(x1)), rep(2, ncol(x2)))



# Add a model save path in the path settings section
MODEL_SAVE_DIR <- "/"
if(!dir.exists(MODEL_SAVE_DIR)) dir.create(MODEL_SAVE_DIR, recursive = TRUE)


cat("\n--- Starting the 10-fold cross-validation loop ---\n")

for (i in 1:10) {
  
  cat(paste0("\n------------------ Processing fold ", i, "/10 ------------------\n"))
  
  # Define training and test sets
  test_indices <- folds[[i]]
  train_indices <- setdiff(1:length(y), test_indices)
  
  x_train <- x[train_indices, ]
  y_train <- y[train_indices]
  x_test <- x[test_indices, ]
  y_test <- y[test_indices]
  
  # Train the StaPLR model
  cat("  -> Training model...\n")
  fit <- StaPLR(x = x_train, y = y_train, view = view, family = "binomial", progress = FALSE)
  
  # Save the model for the current fold
  model_filename <- paste0(MODEL_SAVE_DIR, "StaPLR_fold_", i, ".rds")
  saveRDS(fit, file = model_filename)
  cat(paste0(" [Model saved] "))
  
  
  # Save view weights for the current fold
  fold_view_weights[[i]] <- coef(fit)$meta
  
  # Make predictions and calculate scores for both Train and Test
  
  # --- Test set prediction ---
  pred_score_test <- predict(fit, newx = x_test, predtype = "link")[, "lambda.min"]
  pred_class_test <- as.numeric(predict(fit, newx = x_test, predtype = "class")[, "lambda.min"])
  
  # --- Training set prediction ---
  pred_score_train <- predict(fit, newx = x_train, predtype = "link")[, "lambda.min"]
  pred_class_train <- as.numeric(predict(fit, newx = x_train, predtype = "class")[, "lambda.min"])
  
  
  # Store detailed results for the current fold, including both Train and Test
  
  # Construct test set results
  df_test <- data.frame(
    Sample_Name = sample_names[test_indices],
    Fold = i,
    Set_Type = "Test",
    True_Label_Code = y_test,
    True_Label = ifelse(y_test == 1, "Healthy", "Disease"),
    Predicted_Score = as.numeric(pred_score_test),
    Predicted_Class_Code = pred_class_test,
    Predicted_Label = ifelse(pred_class_test == 1, "Healthy", "Disease"),
    Is_Correct = ifelse(y_test == pred_class_test, "Yes", "No")
  )
  
  # Construct training set results
  df_train <- data.frame(
    Sample_Name = sample_names[train_indices],
    Fold = i,
    Set_Type = "Train",
    True_Label_Code = y_train,
    True_Label = ifelse(y_train == 1, "Healthy", "Disease"),
    Predicted_Score = as.numeric(pred_score_train),
    Predicted_Class_Code = pred_class_train,
    Predicted_Label = ifelse(pred_class_train == 1, "Healthy", "Disease"),
    Is_Correct = ifelse(y_train == pred_class_train, "Yes", "No")
  )
  
  # Combine and store in the list
  all_predictions_list[[i]] <- rbind(df_train, df_test)
  

  
  # Print detailed information
  cat("  -> Accuracy details for fold ", i, ":\n")
  cat(paste0("     [Training set] Overall accuracy: ", round(acc_train_overall * 100, 2), "%\n"))
  cat(paste0("                    Healthy samples: ", round(acc_train_healthy * 100, 2), "%\n"))
  cat(paste0("                    Disease samples: ", round(acc_train_disease * 100, 2), "%\n"))
  cat(paste0("     [Test set] Overall accuracy: ", round(acc_test_overall * 100, 2), "%\n"))
  cat(paste0("                Healthy samples: ", round(acc_test_healthy * 100, 2), "%\n"))
  cat(paste0("                Disease samples: ", round(acc_test_disease * 100, 2), "%\n"))
}

# Combine and save results
cat("\n\n--- Cross-validation completed. Saving detailed results for all folds ---\n")


final_combined_results <- do.call(rbind, all_predictions_list)


tryCatch({
  write.csv(final_combined_results, file = OUTPUT_CSV_PATH, row.names = FALSE)
  cat(paste0("\nSuccess! The scoring results for all training and test samples across the 10 folds have been saved to:\n   ", OUTPUT_CSV_PATH, "\n"))
}, error = function(e) {
  cat(paste0("\nError: Unable to save the file. Please check whether the path is correct and whether you have write permission.\n   Error message: ", e$message, "\n"))
})


# Print overall statistical summary
cat("\n--- Average statistical summary of 10-fold cross-validation ---\n")
mean_metrics <- colMeans(accuracy_metrics[, -1])

cat("  -> [Average training set] Overall: ", round(mean_metrics["train_overall"] * 100, 2), "%, Healthy: ", round(mean_metrics["train_healthy"] * 100, 2), "%, Disease: ", round(mean_metrics["train_disease"] * 100, 2), "%\n")
cat("  -> [Average test set] Overall: ", round(mean_metrics["test_overall"] * 100, 2), "%, Healthy: ", round(mean_metrics["test_healthy"] * 100, 2), "%, Disease: ", round(mean_metrics["test_disease"] * 100, 2), "%\n")


# Print average view weights
avg_weights_matrix <- do.call(rbind, lapply(fold_view_weights, as.matrix))
avg_view_weights <- colMeans(avg_weights_matrix)
cat("\n--- Average view weights from 10-fold cross-validation ---\n")
print(avg_view_weights)