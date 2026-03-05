library(tidyverse)

# Lire les données
df <- read_tsv("final_recombination_combined.tsv")

# Transformer en format long
df_long <- df %>%
  pivot_longer(
    cols = matches("Fresh|Salt"),   # garde toutes les colonnes avec "Fresh" ou "Salt"
    names_to = "pop_col",
    values_to = "recombination"
  ) %>%
  filter(!str_detect(pop_col, "Simulated")) %>%  # exclure les colonnes "Simulated"
  mutate(
    population = case_when(
      str_detect(pop_col, "Fresh") ~ "Fresh",
      str_detect(pop_col, "Salt") ~ "Salt"
    )
  )

# Résumer par chromosome et population
recomb_summary <- df_long %>%
  group_by(Chr, population) %>%
  summarise(
    recomb_5th = quantile(recombination, 0.05, na.rm = TRUE),
    recomb_median = median(recombination, na.rm = TRUE),
    recomb_95th = quantile(recombination, 0.95, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(Chr = factor(Chr, levels = rev(unique(df$Chr))))  # facultatif : ordre inversé des chromosomes
  
#recomb_summary <- df_long %>%
#  group_by(Chr, Start, population) %>%
#  summarise(
#    recomb_median = median(recombination, na.rm = TRUE),
#    .groups = "drop"
#  )
  
# Afficher ou utiliser le résumé
print(recomb_summary)

write_tsv(recomb_summary, "recombination_summary_by_chr_population.tsv")
