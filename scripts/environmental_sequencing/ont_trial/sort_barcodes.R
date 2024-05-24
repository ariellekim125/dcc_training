#!/usr/bin/env Rscript

# Load required packages and functions
library(tidyverse)
library(spgs) # statistical hypothesis tests and other techniques for DNA sequences

# Function to add sequencing barcode ids to a table with dna ids
# dna_id_df         A data frame with the DNA ids. 
# sample_indices    Integer vector with the sample indices to which the barcodes will be added
# barcode_indices   Integer vector with the barcode indices used. Order must match sample_indices
add_barcode_ids <- function(dna_id_df, sample_indices, barcode_indices) {
  # Generate table relating barcodes with sample indices
  plate_col <- LETTERS[seq(1,8)]
  # seq(from, to) generates sequences
  plate_row <- seq(1,12)
  barcode_df <- crossing(plate_col, plate_row) %>%
    # crossing is wrapper around expand_grid, but also de-duplicates and sorts
    # does this create many different combinations of the diff columns and rows?
    arrange(plate_row) %>%
    # orders data frame by the values of plate_row
    mutate(plate_well = paste(plate_col, plate_row, sep = "")) %>%
    # concatenates vectors after converting to character, var plate_well = single string
    add_column( barcode_id = paste("bc", seq(1:96), sep = "")) %>%
    # adds column named barcode_id with values with bc + numbers from 1 to 96 concat
    group_by(plate_row) %>%
    # groups lines by plate_row
    arrange(desc(plate_col), .by_group = T) %>%
    # arranges lines by descending plate_col values
    add_column(barcode_index = seq(1:96)) %>%
    # adds columns with barcode indexes from 1 to 96
    ungroup() %>%
    # ungroups after group_by
    select(barcode_id, barcode_index)
    # selects these two columns 
  #
  index_key <- tibble(sample_index = sample_indices, barcode_index = barcode_indices)
  # creates tibble with sample_index and barcode_index, not sure what equals is doing
  dna_id_df <- dna_id_df %>%
    # mutating dna_id_df with following
    add_column(sample_index = seq(1, nrow(.))) %>%
    # add column named sample_index, seq from 1 to number of rows
    left_join(index_key, by = "sample_index") %>%
    # left joining with sample_index, mutates index_key tibble
    # retains all from dna_id_df, some index_key may be lost
    left_join(barcode_df, by = "barcode_index")
  dna_id_df
  # left joining with barcode_index, mutates barcode_df tibble
  
}

# Generate a table with the barcode sequences in both orientations
barcoded_16s_forward <- read_csv(file = "documents/tables/barcoded_16s_forward.csv") %>%
  # need this file above^
  mutate(barcode_id = str_replace(Name, "bc0*", "bc")) %>%
  mutate(barcode_id = str_remove(barcode_id, "F")) %>%
  mutate(f_primer_f_sequence = str_to_upper(Sequence)) %>%
  mutate(f_barcode_f_sequence = str_remove(f_primer_f_sequence, "AGAGTTTGATCCTGGCTCAG")) %>%
  # remove primer sequences to isolate barcode sequences
  mutate(f_barcode_r_sequence = reverseComplement(f_barcode_f_sequence)) %>%
  # reverse complement of forward sequence
  mutate(f_barcode_r_sequence = str_to_upper(f_barcode_r_sequence)) %>%
  select(barcode_id, f_barcode_f_sequence, f_barcode_r_sequence, f_primer_f_sequence)
barcoded_16s_reverse <- read_csv(file = "documents/tables/barcoded_16s_reverse.csv") %>%
  # need this file above^
  mutate(barcode_id = str_replace(Name, "bc0*", "bc")) %>%
  mutate(barcode_id = str_remove(barcode_id, "R")) %>%
  mutate(r_primer_f_sequence = str_to_upper(Sequence)) %>%
  mutate(r_primer_r_sequence = reverseComplement(r_primer_f_sequence)) %>%
  mutate(r_primer_r_sequence = str_to_upper(r_primer_r_sequence)) %>%
  mutate(r_barcode_f_sequence = str_remove(r_primer_f_sequence, "GGTTACCTTGTTACGACTT")) %>%
  mutate(r_barcode_r_sequence = reverseComplement(r_barcode_f_sequence)) %>%
  mutate(r_barcode_r_sequence = str_to_upper(r_barcode_r_sequence)) %>%
  select(barcode_id, r_barcode_f_sequence, r_barcode_r_sequence, r_primer_r_sequence)
barcoded_16s_full <- barcoded_16s_forward %>%
  left_join(barcoded_16s_reverse, by = "barcode_id")
# keep everything in forward, join by barcode_id to form full table
# Load table with dna codes for ont env trial samples and add barcode info
env_dna_codes_trial_barcoded <- read_csv(file = "documents/tables/env_dna_codes_trial.csv") %>%
  # need this file above^
  add_barcode_ids(sample_indices = c(seq(1, 48), seq(97, 104), seq(49, 96), seq(105, 117)),
                  barcode_indices = c(seq(1, 48), seq(89, 96), seq(49, 96), seq(1, 13))) %>%
  # function above, adds barcode information to DNA codes
  left_join(barcoded_16s_full, by = "barcode_id") %>%
  mutate(pool = case_when(
    between(sample_index, 1, 48) ~ "pool1",
    between(sample_index, 49, 96) ~ "pool2",
    between(sample_index, 97, 104) ~ "pool1",
    between(sample_index, 105, 117) ~ "pool2"
    # this separates between pool 1 and 2, when sample index between 1 and 48, pool = 1
  ))
# Export barcode files for demultiplexing
if (!dir.exists("analyses/environmental_sequencing/ont_trial/demultiplex/")) {
  dir.create("analyses/environmental_sequencing/ont_trial/demultiplex/", recursive = T)
}
# create directory if it does not exist, pools will be separated
## Pool 1
env_dna_codes_trial_barcoded %>%
  filter(pool == "pool1") %>%
  # select those in pool1
  select(dna_code, f_barcode_f_sequence) %>%
  mutate(dna_code = paste(dna_code, "_f", sep = "")) %>%
  # mutate the dna code by combining code and f
  write_delim(file = "analyses/environmental_sequencing/ont_trial/demultiplex/barcodes_pool1_f_f.tsv", 
              delim = "\t", col_names = F)
# sample ids along w/ forward and reverse primer sequences written to TSV file
env_dna_codes_trial_barcoded %>%
  filter(pool == "pool1") %>%
  select(dna_code, r_barcode_r_sequence) %>%
  mutate(dna_code = paste(dna_code, "_r", sep = "")) %>%
  write_delim(file = "analyses/environmental_sequencing/ont_trial/demultiplex/barcodes_pool1_r_r.tsv", 
              delim = "\t", col_names = F)
## Pool 2
env_dna_codes_trial_barcoded %>%
  filter(pool == "pool2") %>%
  select(dna_code, f_barcode_f_sequence) %>%
  mutate(dna_code = paste(dna_code, "_f", sep = "")) %>%
  write_delim(file = "analyses/environmental_sequencing/ont_trial/demultiplex/barcodes_pool2_f_f.tsv", 
              delim = "\t", col_names = F)
env_dna_codes_trial_barcoded %>%
  filter(pool == "pool2") %>%
  select(dna_code, r_barcode_r_sequence) %>%
  mutate(dna_code = paste(dna_code, "_r", sep = "")) %>%
  write_delim(file = "analyses/environmental_sequencing/ont_trial/demultiplex/barcodes_pool2_r_r.tsv", 
              delim = "\t", col_names = F)
# Print files with list of samples in each pool
env_dna_codes_trial_barcoded %>%
  filter(pool == "pool1") %>%
  pull(dna_code) %>%
  write(file = "misc_files/environmental_sequencing/ont_trial/pool1_samples.txt")
env_dna_codes_trial_barcoded %>%
  filter(pool == "pool2") %>%
  pull(dna_code) %>%
  write(file = "misc_files/environmental_sequencing/ont_trial/pool2_samples.txt")
# Print file with sample ids and barcode-16s primer combinations for trimming
env_dna_codes_trial_barcoded %>%
  select(dna_code, f_primer_f_sequence, r_primer_r_sequence) %>%
  write_delim(file = "analyses/environmental_sequencing/ont_trial/demultiplex/barcoded_primers.tsv", 
              delim = "\t", col_names = F)
