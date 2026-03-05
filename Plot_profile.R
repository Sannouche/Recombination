library(tidyverse)
library(wesanderson)
library(paletteer)

# ---- 1. Charger les données ----
input_file <- "final_recombination_combined.tsv"
df <- read_tsv(input_file, col_types = cols())

# Reshaping the data to long format
df_long <- df %>%
  pivot_longer(
    cols = starts_with("mean_r_"),
    names_to = c("Population", "Subset", "Replicate"),
    names_pattern = "mean_r_([^_]+)_([^_]+)_([^_]+)",
    values_to = "Mean_R"
  )
  
df_long <- df_long %>% filter(!is.na(Mean_R))

#df_long <- df_long %>%
#  group_by(Population) %>%
#  mutate(
#    q1 = quantile(Mean_R, 0.01, na.rm = TRUE),
#    q99 = quantile(Mean_R, 0.99, na.rm = TRUE),
#    Mean_R_wins = pmin(pmax(Mean_R, q1), q99)
#  ) %>%
#  ungroup()
  
#recomb_summary <- df_long %>%
#  filter(!Replicate %in% c("Simulated")) %>%
#  group_by(Chr, Start, End, Population) %>%
#  summarise(
#    Min_R = min(Mean_R_wins, na.rm = TRUE),
#    Max_R = max(Mean_R_wins, na.rm = TRUE),
#    Median_R = median(Mean_R_wins, na.rm = TRUE),
#    .groups = "drop"
#  ) %>%
#  mutate(Start_Mb = Start / 1e6)

recomb_summary <- df_long %>%
  filter(!Replicate %in% c("Simulated")) %>%
  group_by(Chr, Start, End, Population) %>%
  summarise(
    Min_R = min(Mean_R, na.rm = TRUE),
    Max_R = max(Mean_R, na.rm = TRUE),
    Median_R = median(Mean_R, na.rm = TRUE),
    .groups = "drop"
  )
  
recomb_summary <- recomb_summary %>%
  mutate(Start_Mb = Start / 1e6)
  
recomb_summary <- recomb_summary %>%
  mutate(Population = recode(Population,
                             "Fresh" = "Fluvial",
                             "Salt" = "Marine"))
                             
recomb_summary <- recomb_summary %>%
  mutate(Population = factor(Population,
                             levels = c("Marine", "Fluvial")))                             

# Create the density plot
p <- ggplot(recomb_summary,
            aes(x = Start_Mb, y = Median_R,
                color = Population, group = Population)) +
  geom_line(linewidth = 0.4, alpha = 0.9) +
  facet_wrap(~Chr, scales = "free_x") +
  coord_cartesian(ylim = c(0, 2e-06)) +
  theme_minimal() +
  labs(x = "Position (Mb)", y = "Recombination rate") +
  scale_color_manual(values = c(Fluvial = "#FBA72AFF",
                                Marine = "#5785C1FF")) +
  theme(strip.text = element_text(size = 9),
        legend.position = "top")

        
ggsave("recombination_profile.png", plot = p, width = 8, height = 6, dpi = 300)

# Representation by quantiles
quant_genome <- df_long %>%
  filter(!Replicate %in% "Simulated") %>%
  mutate(Population = recode(Population,
                             "Fresh" = "Fluvial",
                             "Salt"  = "Marine")) %>%
  group_by(Population) %>%
  summarise(
    Quantile = list(seq(0.01, 0.99, 0.01)),
    Recomb   = list(quantile(Mean_R,
                             probs = seq(0.01, 0.99, 0.01),
                             na.rm = TRUE)),
    .groups = "drop"
  ) %>%
  unnest(c(Quantile, Recomb))
p_quant_genome <- ggplot(quant_genome,
                         aes(x = Quantile *100, y = Recomb,
                             color = Population)) +
  geom_line(linewidth = 1) +
  scale_y_continuous(labels = scales::scientific) +
  theme_minimal() +
  labs(x = "Quantile",
       y = "Recombination rate") +
  scale_color_manual(values = c(Fluvial = "#FBA72AFF",
                                Marine  = "#5785C1FF")) +
  theme(legend.position = "top")

ggsave("recombination_quantiles.png", plot = p_quant_genome, width = 8, height = 6, dpi = 300)

# Same but by chromosome
quant_chr <- df_long %>%
  filter(!Replicate %in% "Simulated") %>%
  mutate(Population = recode(Population,
                             "Fresh" = "Fluvial",
                             "Salt"  = "Marine")) %>%
  group_by(Chr, Population) %>%
  summarise(
    Quantile = list(seq(0.01, 0.99, 0.01)),
    Recomb   = list(quantile(Mean_R,
                             probs = seq(0.01, 0.99, 0.01),
                             na.rm = TRUE)),
    .groups = "drop"
  ) %>%
  unnest(c(Quantile, Recomb))

p_quant_chr <- ggplot(quant_chr,
                      aes(x = Quantile *100, y = Recomb,
                          color = Population)) +
  geom_line(linewidth = 0.8) +
  facet_wrap(~Chr, scales = "free_y") +
  coord_cartesian(ylim = c(0, 2e-06)) +
  theme_minimal() +
  labs(x = "Quantile",
       y = "Recombination rate") +
  scale_color_manual(values = c(Fluvial = "#FBA72AFF",
                                Marine  = "#5785C1FF")) +
  theme(strip.text = element_text(size = 9),
        legend.position = "top")

ggsave("recombination_quantiles_bychr.png", plot = p_quant_chr, width = 8, height = 6, dpi = 300)

# We also do density plot
p_density_chr <- ggplot(
  df_long %>%
    filter(!Replicate %in% "Simulated") %>%
    mutate(Population = recode(Population,
                               "Fresh" = "Fluvial",
                               "Salt"  = "Marine")),
  aes(x = Mean_R, color = Population, fill = Population)
) +
  geom_density(linewidth = 0.8, alpha = 0.3, adjust = 1.2) +
  facet_wrap(~Chr, scales = "free_x") +
  scale_x_continuous(labels = scales::scientific) +
  theme_minimal() +
  labs(x = "Recombination rate",
       y = "Density") +
  scale_color_manual(values = c(Fluvial = "#FBA72AFF",
                                Marine  = "#5785C1FF")) +
  scale_fill_manual(values = c(Fluvial = "#FBA72AFF",
                               Marine  = "#5785C1FF")) +
  theme(strip.text = element_text(size = 9),
        legend.position = "top")

ggsave("recombination_density_bychr.png", plot = p_density_chr, width = 8, height = 6, dpi = 300)        