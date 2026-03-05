library(dplyr)
library(tidyr)
library(readr)

# Définir le dossier contenant les fichiers
input_dir <- "10_recombination_map/By_window"

# Lister tous les fichiers correspondant au format attendu
files <- list.files(input_dir, pattern = "_2kb_avg.bed$", full.names = TRUE)

# Fonction pour extraire Population, Site et Réplicat depuis le nom du fichier
extract_info <- function(filename) {
  # Extract the base name (remove the directory path)
  base_name <- basename(filename)

  # Regular expression to match the expected pattern
  pattern <- "^(Freshwater|Saltwater)_S([12])_R([123])_allchr_2kb_avg\\.bed$"

  matches <- regmatches(base_name, regexec(pattern, base_name))

  if (length(matches[[1]]) == 4) {
    return(list(
      Population = matches[[1]][2],  # "Freshwater" or "Saltwater"
      Site = paste0("S", matches[[1]][3]), # "S1" or "S2"
      Replicate = paste0("R", matches[[1]][4]) # "R1", "R2", or "R3"
    ))
  } else {
    return(NULL) # Return NULL if filename does not match expected pattern
  }
}

# Lire et stocker toutes les données
data_list <- list()

 for (file in files) {
  info <- extract_info(file)
  if (!is.null(info)) {
    df <- read_tsv(file, col_names = c("Chr", "Start", "End", "Mean_r"))
    df <- df %>%
      select(Chr, Start, End, Mean_r) %>%
      mutate(Population = info$Population, Site = info$Site, Replicate = info$Replicate)
    data_list[[file]] <- df
  }
}

# Combiner toutes les données en une seule table
all_data <- bind_rows(data_list)

# Réorganiser les données pour obtenir une colonne par combinaison Population/Site
final_data <- all_data %>%
  pivot_wider(names_from = c(Population, Site), values_from = Mean_r, names_prefix = "mean_r_") %>%
  arrange(Chr, Start)

# Séparer les données par réplicat et écrire les fichiers de sortie
for (replicate in c("R1", "R2", "R3")) {
  output_file <- paste0("final_recombination_", replicate, ".tsv")
  
  final_data_rep <- final_data %>%
    filter(Replicate == replicate) %>%
    select(-Replicate) # Supprimer la colonne Réplicat qui n'est plus nécessaire
  
  write_tsv(final_data_rep, output_file)
  cat("? Output saved:", output_file, "\n")
}
