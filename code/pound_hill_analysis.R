
# ============================================================
# Pound Hill plant data analysis
# Data wrangling: dplyr and tidyr
# Visualisation: ggplot2
#
# Run from the project root:
# Rscript code/pound_hill_analysis.R
# ============================================================


# 1. Load packages --------------------------------------------

library(dplyr)
library(tidyr)
library(ggplot2)


# 2. Set up output directory ----------------------------------

if (!dir.exists("results")) {
  dir.create("results", recursive = TRUE)
}


# 3. Import raw data and metadata ------------------------------

raw_data <- read.csv(
  "data/pound_hill_data.csv",
  header = FALSE,
  stringsAsFactors = FALSE,
  check.names = FALSE,
  colClasses = "character",
  na.strings = character(0)
)

metadata <- read.csv(
  "data/pound_hill_meta_data.csv",
  sep = ";",
  header = TRUE,
  stringsAsFactors = FALSE,
  colClasses = "character"
)

cat("RAW DATA DIMENSIONS\n")
print(dim(raw_data))

cat("\nRAW DATA COLUMN TYPES\n")
str(raw_data)

cat("\nFIRST SIX ROWS OF RAW DATA\n")
print(head(raw_data))

cat("\nMETADATA DIMENSIONS\n")
print(dim(metadata))

cat("\nMETADATA COLUMN TYPES\n")
str(metadata)

cat("\nFIRST SIX ROWS OF METADATA\n")
print(head(metadata))

cat("\nFULL METADATA\n")
print(metadata)


# 4. Transpose and clean the data ------------------------------

# The raw data has no header row.
# Transpose it so that each row represents a quadrat.
transposed_data <- as.data.frame(
  t(as.matrix(raw_data)),
  stringsAsFactors = FALSE
)

# The first row contains the column names.
column_names <- as.character(
  unlist(transposed_data[1, ], use.names = FALSE)
)

names(transposed_data) <- column_names

# Remove the row containing the column names.
MyWrangledData <- transposed_data[-1, , drop = FALSE]
rownames(MyWrangledData) <- NULL

# Identify the sampling-unit columns.
id_columns <- c(
  "Cultivation",
  "Block",
  "Plot",
  "Quadrat"
)

if (!all(id_columns %in% names(MyWrangledData))) {
  stop(
    "Expected identifier columns were not found. ",
    "Check the raw data and its first row."
  )
}

# Remaining columns contain species counts.
species_columns <- setdiff(
  names(MyWrangledData),
  id_columns
)

cat("\nNUMBER OF SPECIES COLUMNS\n")
print(length(species_columns))


# 5. Handle blank species counts -------------------------------

# For this particular Pound Hill dataset, the practical treats
# blank species-count cells as observed absences. This justifies
# replacing blanks with zero for these data.
#
# This is a dataset-specific decision, not a general rule:
# in another dataset, a blank could mean missing information.
#
# Only species-count columns are changed; identifiers are kept.

MyWrangledData[species_columns] <- lapply(
  MyWrangledData[species_columns],
  function(x) {
    x <- trimws(as.character(x))
    x[is.na(x) | x == ""] <- "0"
    x
  }
)


# 6. Reshape from wide to long format --------------------------

MyWrangledData <- MyWrangledData %>%
  pivot_longer(
    cols = all_of(species_columns),
    names_to = "Species",
    values_to = "Count"
  ) %>%
  mutate(
    Cultivation = trimws(Cultivation),
    Block = trimws(Block),
    Plot = trimws(Plot),
    Quadrat = trimws(Quadrat),
    Species = trimws(Species)
  )

cat("\nLONG-FORMAT DIMENSIONS\n")
print(dim(MyWrangledData))

cat("\nFIRST SIX ROWS OF LONG-FORMAT DATA\n")
print(head(MyWrangledData))

cat("\nCOLUMN TYPES AFTER RESHAPING\n")
str(MyWrangledData)


# 7. Validate the transformed data -----------------------------

# Convert counts to numeric.
MyWrangledData$Count <- suppressWarnings(
  as.numeric(MyWrangledData$Count)
)

if (anyNA(MyWrangledData$Count) ||
    any(!is.finite(MyWrangledData$Count))) {
  stop("Counts contain missing or non-numeric values.")
}

if (any(MyWrangledData$Count < 0)) {
  stop("Negative species counts were found.")
}

if (any(MyWrangledData$Count != floor(MyWrangledData$Count))) {
  stop("Species counts should be whole numbers.")
}

MyWrangledData$Count <- as.integer(MyWrangledData$Count)

if (anyNA(MyWrangledData[id_columns]) ||
    any(vapply(
      MyWrangledData[id_columns],
      function(x) any(trimws(x) == ""),
      logical(1)
    ))) {
  stop("Missing or blank sampling identifiers were found.")
}

# Check cultivation labels.
expected_treatments <- c("october", "may", "march")

if (!all(unique(MyWrangledData$Cultivation) %in%
         expected_treatments)) {
  stop("Unexpected cultivation treatment labels were found.")
}

# Count distinct species.
number_species <- n_distinct(MyWrangledData$Species)

# A quadrat is identified by all four labels together.
number_quadrats <- MyWrangledData %>%
  distinct(Cultivation, Block, Plot, Quadrat) %>%
  nrow()

# A plot is identified by cultivation, block, and plot together.
number_plots <- MyWrangledData %>%
  distinct(Cultivation, Block, Plot) %>%
  nrow()

cat("\nDATA VALIDATION RESULTS\n")
cat("------------------------------\n")
cat("Counts are numeric and non-negative: PASS\n")
cat("Number of species:", number_species, "\n")
cat("Number of quadrats:", number_quadrats, "\n")
cat("Number of plots:", number_plots, "\n")

# Inspect the number of quadrats per plot.
quadrats_per_plot <- MyWrangledData %>%
  distinct(Cultivation, Block, Plot, Quadrat) %>%
  count(Cultivation, Block, Plot, name = "NumberOfQuadrats")

cat("\nQUADRATS PER PLOT\n")
print(quadrats_per_plot, n = Inf)

# The practical expects 12 plots.
if (number_plots != 12) {
  stop(
    "Expected 12 plots but found ", number_plots,
    ". Check the data before continuing."
  )
}


# 8. Calculate richness and abundance per quadrat --------------

# Richness = number of species with a count greater than zero.
# Abundance = sum of the counts of all species.

quadrat_summary <- MyWrangledData %>%
  group_by(Cultivation, Block, Plot, Quadrat) %>%
  summarise(
    Richness = sum(Count > 0),
    Abundance = sum(Count),
    .groups = "drop"
  )

cat("\nFIRST SIX QUADRAT-LEVEL SUMMARIES\n")
print(head(quadrat_summary))


# 9. Calculate plot-level mean richness and abundance ----------

# Each plot appears once. Its response is averaged across the
# quadrats observed in that plot.

plot_summary <- quadrat_summary %>%
  group_by(Cultivation, Block, Plot) %>%
  summarise(
    MeanRichness = mean(Richness),
    MeanAbundance = mean(Abundance),
    NumberOfQuadrats = n(),
    .groups = "drop"
  ) %>%
  mutate(
    Cultivation = factor(
      Cultivation,
      levels = expected_treatments
    )
  ) %>%
  arrange(Cultivation, Block, Plot)

# Verify one row per plot and exactly 12 plot-level records.
if (anyDuplicated(
  plot_summary[c("Cultivation", "Block", "Plot")]
) > 0) {
  stop("Duplicate plots found in the plot-level summary.")
}

if (nrow(plot_summary) != 12) {
  stop("The plot-level summary does not contain 12 plots.")
}

cat("\nPLOT-LEVEL SUMMARY\n")
print(plot_summary, n = Inf)


# 10. Save the summary tables ---------------------------------

# Required richness table.
write.csv(
  plot_summary %>%
    select(Cultivation, Block, Plot, MeanRichness),
  "results/pound_hill_plot_richness.csv",
  row.names = FALSE
)

# Additional abundance table requested by the practical.
write.csv(
  plot_summary %>%
    select(Cultivation, Block, Plot, MeanAbundance),
  "results/pound_hill_plot_abundance.csv",
  row.names = FALSE
)


# 11. Define a consistent botanical visual style ---------------

plant_colours <- c(
  "october" = "#52796F",  # Sage green
  "may"     = "#D08C60",  # Terracotta
  "march"   = "#7B8FA1"   # Muted slate blue
)

theme_plant <- function() {
  theme_minimal(base_size = 12) +
    theme(
      plot.title = element_text(
        size = 17,
        face = "bold",
        colour = "#344E41",
        hjust = 0.5,
        margin = margin(b = 10)
      ),
      plot.subtitle = element_text(
        size = 11,
        colour = "#68756D",
        hjust = 0.5,
        margin = margin(b = 20)
      ),
      axis.title.x = element_text(
        size = 12,
        face = "bold",
        colour = "#344E41",
        hjust = 0.5,
        margin = margin(t = 12)
      ),
      axis.title.y = element_text(
        size = 12,
        face = "bold",
        colour = "#344E41",
        hjust = 0.5,
        margin = margin(r = 12)
      ),
      axis.text = element_text(
        size = 10,
        colour = "#4A5750"
      ),
      panel.grid.minor = element_blank(),
      panel.grid.major.x = element_blank(),
      panel.grid.major.y = element_line(
        colour = "#E3E8E3",
        linewidth = 0.5
      ),
      panel.background = element_rect(
        fill = "#FAFBF8",
        colour = NA
      ),
      plot.background = element_rect(
        fill = "#FAFBF8",
        colour = NA
      ),
      plot.margin = margin(20, 22, 20, 22)
    )
}


# 12. Plot species richness ------------------------------------

p_richness <- ggplot(
  plot_summary,
  aes(
    x = Cultivation,
    y = MeanRichness,
    fill = Cultivation,
    colour = Cultivation
  )
) +
  geom_boxplot(
    width = 0.52,
    alpha = 0.45,
    linewidth = 0.8,
    outlier.shape = NA,
    colour = "#344E41"
  ) +
  geom_jitter(
    width = 0.10,
    height = 0,
    size = 3,
    alpha = 0.9
  ) +
  scale_fill_manual(values = plant_colours) +
  scale_colour_manual(values = plant_colours) +
  labs(
    title = "Plant Species Richness at Pound Hill",
    subtitle = "Mean quadrat richness for each plot",
    x = "Cultivation treatment",
    y = "Mean species richness per quadrat"
  ) +
  guides(
    fill = "none",
    colour = "none"
  ) +
  theme_plant()

print(p_richness)

ggsave(
  "results/pound_hill_plot_richness.pdf",
  plot = p_richness,
  width = 8,
  height = 6,
  bg = "#FAFBF8"
)


# 13. Plot total plant abundance -------------------------------

p_abundance <- ggplot(
  plot_summary,
  aes(
    x = Cultivation,
    y = MeanAbundance,
    fill = Cultivation,
    colour = Cultivation
  )
) +
  geom_boxplot(
    width = 0.52,
    alpha = 0.45,
    linewidth = 0.8,
    outlier.shape = NA,
    colour = "#344E41"
  ) +
  geom_jitter(
    width = 0.10,
    height = 0,
    size = 3,
    alpha = 0.9
  ) +
  scale_fill_manual(values = plant_colours) +
  scale_colour_manual(values = plant_colours) +
  labs(
    title = "Total Plant Abundance at Pound Hill",
    subtitle = "Mean total plant count per quadrat for each plot",
    x = "Cultivation treatment",
    y = "Mean total plant count per quadrat"
  ) +
  guides(
    fill = "none",
    colour = "none"
  ) +
  theme_plant()

print(p_abundance)

ggsave(
  "results/pound_hill_plot_abundance.pdf",
  plot = p_abundance,
  width = 8,
  height = 6,
  bg = "#FAFBF8"
)


# 14. Compare treatment patterns -------------------------------

treatment_summary <- plot_summary %>%
  group_by(Cultivation) %>%
  summarise(
    NumberOfPlots = n(),
    MedianRichness = median(MeanRichness),
    SDRichness = sd(MeanRichness),
    MinRichness = min(MeanRichness),
    MaxRichness = max(MeanRichness),
    MedianAbundance = median(MeanAbundance),
    SDAbundance = sd(MeanAbundance),
    MinAbundance = min(MeanAbundance),
    MaxAbundance = max(MeanAbundance),
    .groups = "drop"
  )

cat("\nTREATMENT COMPARISON\n")
print(treatment_summary, n = Inf)

write.csv(
  treatment_summary,
  "results/pound_hill_treatment_summary.csv",
  row.names = FALSE
)


# 15. Interpretation -------------------------------------------
#
# Richness: after inspecting the figure, identify the treatment
# with the highest typical plot-level mean richness and describe
# how variable the plots are within each treatment.
#
# Abundance: compare its pattern with richness. Abundance measures
# the number of individuals, whereas richness measures the number
# of species present. A treatment may have many individuals but
# relatively few species if a small number of species dominate.
#
# Neither figure alone proves that cultivation timing caused
# the observed differences. We would need details of treatment
# allocation, randomisation, replication, and blocking, as well
# as an appropriate statistical analysis of the experimental
# design, to assess evidence for a treatment effect.


# 16. Completion message ---------------------------------------

cat("\nAnalysis completed successfully.\n")
cat("Saved results in the results/ directory:\n")
cat("- pound_hill_plot_richness.csv\n")
cat("- pound_hill_plot_abundance.csv\n")
cat("- pound_hill_treatment_summary.csv\n")
cat("- pound_hill_plot_richness.pdf\n")
cat("- pound_hill_plot_abundance.pdf\n")

# ============================================================
# End of analysis
# ============================================================
