# load required packages and functions
if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install("phyloseq") # install phyloseq
install.packages("patchwork") # install patchwork to chart plots
library("phyloseq")
library("ggplot2")
library("patchwork")
library(tidyverse)

# create the phyloseq object
merged_data <- import_biom("analyses/environmental_sequencing/ont_trial/biom/ont_trial.biom")

# remove unnecessary characters
merged_data@tax_table@.Data <- substring(merged_data@tax_table@.Data, 4)

# add appropriate column names
colnames(merged_data@tax_table@.Data)<- c("Kingdom", "Phylum", "Class", "Order", "Family", "Genus", "Species")

#filter out chloroplasts
merged_data <- subset_taxa(merged_data, Class != "Chloroplast")

# filter for bacteria
merged_data <- subset_taxa(merged_data, Kingdom == "Bacteria")

#retain only taxa with valid genus entries
merged_data <- subset_taxa(merged_data, Genus != "")

# transform number of assigned reads into percentages per sample
percentages <- transform_sample_counts(merged_data, function(x) x*100 / sum(x))

# replace brackets in tax table
percentages@tax_table@.Data <- percentages@tax_table@.Data |>
  gsub(pattern = "\\[", replacement = "") |> #bracket is special character
  gsub(pattern = "\\]", replacement = '')

# replace NaN in otu table with 0
percentages@otu_table@.Data[is.nan(percentages@otu_table@.Data)] <- 0

# replace brackets in tables for absolute data too
merged_data@tax_table@.Data <- merged_data@tax_table@.Data |>
  gsub(pattern = "\\[", replacement = "") |> #bracket is special character
  gsub(pattern = "\\]", replacement = '')

# group all OTUs by phylum
percentages_glomPhylum <- tax_glom(percentages, taxrank = 'Phylum')

# melt phyloseq objects into a data frame
percentages_dfPhylum <- psmelt(percentages_glomPhylum)
str(percentages_dfPhylum)

# create data frame with original data
absolute_glomPhylum <- tax_glom(physeq = merged_data, taxrank = "Phylum")
absolute_dfPhylum <- psmelt(absolute_glomPhylum)
str(absolute_df)

# create color palette
absolute_df$Phylum <- as.factor(absolute_df$Phylum)

phylum_colors_abs <- c(
  "Acidobacteria" = "#58508d",        # Blue Violet
  "Actinobacteria" = "#007bba",
  "Armatimonadetes" = "#00b4d8",      # Forest Green
  "Bacteroidetes" = "#56cfe1",
  "Chlamydiae" = "#75a202",
  "Chloroflexi" = "#b5e48c",
  "Cyanobacteria" = "#43aa8b",        # Cyan
  "Elusimicrobia" = "#71093b",        # Saddle Brown
  "Firmicutes" = "#f94144",
  "Fusobacteria" = "#722e9a",         # Purple
  "Gemmatimonadetes" = "#d12e64",
  "Nitrospirae" = "#ff6d00",
  "Planctomycetes" = "#f8961e",
  "Proteobacteria" = "#f9c74f",  # Reddish Orange
  "Spirochaetes" = "#ff477e",         # Dark Violet
  "Tenericutes" = "#ff85a1",          # Pink
  "Thermi" = "#ffffb7",               # Dark Turquoise
  "Verrucomicrobia" = "#da7e37"
)

# create figure with absolute abundances
absolute_plotPhylum <- ggplot(data = absolute_dfPhylum, aes(
  x = Sample, 
  y = Abundance, 
  fill = Phylum)) +
  geom_bar(aes(), stat = "identity", position = "stack") +
  scale_fill_manual(values = phylum_colors_abs)
absolute_plotPhylum

# change identification of OTUs with abundance < 0.2%
percentages_df$Phylum <- as.character(percentages_df$Phylum)
percentages_df$Phylum[percentages_dfPhylum$Abundance < 0.5] <- "Phylum < 0.5% abund."
unique(percentages_df$Phylum)

# create figures for relative abundance data
percentages_dfPhylum$Phylum <- as.factor(percentages_dfPhylum$Phylum)

phylum_colors_rel <- c(
  "Acidobacteria" = "#58508d",        # Blue Violet
  "Actinobacteria" = "#007bba",
  "Armatimonadetes" = "#00b4d8",      # Forest Green
  "Bacteroidetes" = "#56cfe1",
  "Chlamydiae" = "#75a202",
  "Chloroflexi" = "#b5e48c",
  "Cyanobacteria" = "#43aa8b",        # Cyan
  "Elusimicrobia" = "#71093b",        # Saddle Brown
  "Firmicutes" = "#f94144",
  "Fusobacteria" = "#722e9a",         # Purple
  "Gemmatimonadetes" = "#d12e64",
  "Nitrospirae" = "#ff6d00",
  "Planctomycetes" = "#f8961e",
  "Proteobacteria" = "#f9c74f",  # Reddish Orange
  "Spirochaetes" = "#ff477e",         # Dark Violet
  "Tenericutes" = "#ff85a1",          # Pink
  "Thermi" = "#ffffb7",               # Dark Turquoise
  "Verrucomicrobia" = "#da7e37"
  )

relative_plotPhylum <- ggplot(data = percentages_dfPhylum, aes(
  x = Sample,
  y = Abundance,
  fill = Phylum)) +
  geom_bar(aes(), stat = "identity", position = "stack") +
  scale_fill_manual(values = phylum_colors_rel) + 
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
relative_plotPhylum

# facet wrap by site
# group by site
group_labels_phylum <- function(label) {
  ifelse(grepl("^s8_", label), "Site 8", 
         ifelse(grepl("^s10_", label), "Site 10", 
                ifelse(grepl("^s12_", label), "Site 12",
                       ifelse(grepl("^s13_", label), "Site 13",
                              ifelse(grepl("^s15_", label), "Site 15",
                                     "Benchmark")
                       )
                )
         )
  )
}

# create new column for site
percentages_dfPhylum$Site <- group_labels_phylum(percentages_dfPhylum$Sample)

#specify desired site order
site_order <- c("Site 8", "Site 10", "Site 12", "Site 13", "Site 15", "Benchmark")

# reorder sites
percentages_dfPhylum$Site <- factor(percentages_dfPhylum$Site, levels = site_order)

# modify sample names to remove prefix
percentages_dfPhylum <- percentages_dfPhylum |>
  mutate(Sample = case_when(
    Site == "Site 8" ~ str_remove(Sample, "^s8_"),
    Site == "Site 10" ~ str_remove(Sample, "^s10_"),
    Site == "Site 12" ~ str_remove(Sample, "^s12_"),
    Site == "Site 13" ~ str_remove(Sample, "^s13_"),
    Site == "Site 15" ~ str_remove(Sample, "^s15_"),
    TRUE ~ Sample
  ))

# filter out abnormal samples
percentages_dfPhylum <- percentages_dfPhylum |>
  filter(!(Site == "Site 13" & Sample == "14b"),
         !(Site == "Site 8" & Sample == "17b"))

relative_plotPhylum <- ggplot(data = percentages_dfPhylum, aes(
  x = Sample,
  y = Abundance,
  fill = Phylum)) +
  geom_bar(aes(), stat = "identity", position = "stack") +
  scale_fill_manual(values = phylum_colors_rel) + 
  facet_wrap(~ Site, scales = "free") +
  labs(title = "Relative Microbiome Compositions Per Site", x = "Sample Site", y = "Relative Abundance") +
  theme_gray() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
  theme(axis.title.x = element_blank())
relative_plotPhylum

# averages per site
relative_plot_site_Phylum <- ggplot(data = percentages_dfPhylum, aes(
  x = "Sample Site",
  y = Abundance,
  fill = Phylum)) +
  geom_bar(stat = "identity", position = "stack") +
  scale_fill_manual(values = phylum_colors_rel) + 
  facet_wrap(~ Site, scales = "free") +
  labs(title = "Relative Microbiome Compositions Per Site", y = "Relative Abundance") +  # Removed x-axis label
  theme(axis.text.x = element_blank(),    # Remove x-axis tick labels
        axis.title.x = element_blank())
relative_plot_site_Phylum

# try absolute with group labels
# create new column for site
absolute_dfPhylum$Site <- group_labels_phylum(absolute_dfPhylum$Sample)

#specify desired site order
site_order <- c("Site 8", "Site 10", "Site 12", "Site 13", "Site 15", "Benchmark")

absolute_dfPhylum <- absolute_dfPhylum |>
  mutate(Sample = case_when(
    Site == "Site 8" ~ str_remove(Sample, "^s8_"),
    Site == "Site 10" ~ str_remove(Sample, "^s10_"),
    Site == "Site 12" ~ str_remove(Sample, "^s12_"),
    Site == "Site 13" ~ str_remove(Sample, "^s13_"),
    Site == "Site 15" ~ str_remove(Sample, "^s15_"),
    TRUE ~ Sample
  ))

absolute_dfPhylum$Site <- factor(absolute_dfPhylum$Site, levels = site_order)

absolute_plotPhylum <- ggplot(data = absolute_dfPhylum, aes(
  x = Sample, 
  y = log(Abundance), 
  fill = Phylum)) +
  geom_bar(aes(), stat = "identity", position = "stack") +
  scale_fill_manual(values = phylum_colors_abs) + 
  facet_wrap(~ Site, scales = "free_x") +
  theme_gray() + 
  labs(title = "Absolute Microbiome Compositions Per Site", y = "Log(Number of Reads)") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1)) +
  theme(axis.title.x = element_blank())
absolute_plotPhylum
