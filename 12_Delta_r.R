library(dplyr)
library(tidyr)
library(purrr)
library(stringr)
library(readr)

# Lire le fichier
df <- read_tsv("final_recombination_combined.tsv")
df <- df %>%
  mutate(across(starts_with("mean_r_"), as.numeric))

# Identifier les colonnes Freshwater et Saltwater
fresh_cols <- grep("^mean_r_Fresh", names(df), value = TRUE)
salt_cols  <- grep("^mean_r_Salt",  names(df), value = TRUE)
all_maps   <- c(fresh_cols, salt_cols)

df <- df %>%
  filter(!if_all(all_of(all_maps), is.na))

# Créer l'identifiant de bloc (fenêtres de 100kb)
df <- df %>%
  mutate(BlockID = paste0(Chr, "_", floor(Start / 100000)))

# Fonction pour calculer les distances log10 de Manhattan dans chaque bloc
compute_log10_distances_general <- function(block_data) {
  
  block_rates <- block_data %>% select(all_of(all_maps)) %>% t()  # maps x 50
  block_rates <- apply(block_rates, 2, function(x) ifelse(is.na(x), median(x, na.rm = TRUE), x))
  dist_obj <- dist(block_rates, method = "manhattan") / ncol(block_rates)  # diviser par 50
  dist_mat <- as.matrix(dist_obj)
  
  combn_names <- combn(rownames(dist_mat), 2, simplify = FALSE)
  
  dist_df <- map_dfr(combn_names, function(pair) {
    val <- dist_mat[pair[1], pair[2]]
    tibble(
      Pair = paste(pair, collapse = "_vs_"),
      Distance = -log10(abs(val)),
      Map1 = pair[1],
      Map2 = pair[2]
    )
  })
  
  dist_df
}

# Appliquer la fonction à chaque bloc
blockwise_distances <- df %>%
  group_by(BlockID, Chr) %>%
  filter(n() == 50) %>%
  group_map(
    ~ {
      message("Calcul pour bloc : BlockID=", .y$BlockID, " / Chr=", .y$Chr)
      result <- compute_log10_distances_general(.x)
      result$BlockID <- .y$BlockID
      result$Chr <- .y$Chr
      result
    },
    .keep = TRUE
  ) %>%
  bind_rows()


# Ajouter les coordonnées des blocs
block_coords <- df %>%
  group_by(BlockID, Chr) %>%
  summarize(StartBlock = min(Start), .groups = "drop")
  
colnames(blockwise_distances)

blockwise_distances <- blockwise_distances %>%
  left_join(block_coords, by = c("Chr","BlockID"))

# Annoter les types de comparaison
blockwise_distances <- blockwise_distances %>%
  mutate(
    Type = case_when(
      str_detect(Map1, "Fresh") & str_detect(Map2, "Fresh") ~ "intra",
      str_detect(Map1, "Salt")  & str_detect(Map2, "Salt")  ~ "intra",
      TRUE ~ "inter"
    )
  )

# Calculer delta_r_w et delta_r_b par bloc (avec la médiane)
delta_r_summary <- blockwise_distances %>%
  group_by(BlockID, Chr, StartBlock) %>%
  summarize(
    delta_r_w = mean(Distance[Type == "intra"], na.rm = TRUE),
    delta_r_b = mean(Distance[Type == "inter"], na.rm = TRUE),
    .groups = "drop"
  )

# Calcul du seuil pour les outliers
mean_w <- mean(delta_r_summary$delta_r_w, na.rm = TRUE)
sd_w   <- sd(delta_r_summary$delta_r_w, na.rm = TRUE)
threshold <- mean_w + 2 * sd_w

# Identifier les outliers
delta_r_summary <- delta_r_summary %>%
  mutate(Outlier = delta_r_b > threshold)

# Exporter les résultats
write.table(delta_r_summary, "delta_r_summary_all_replicates.tsv", sep = "\t", row.names = FALSE, quote = FALSE)
