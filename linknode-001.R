library(igraph)
library(readr)
library(dplyr)
library(tidyr)
library(stringr)
library(networkD3)

data <- read_csv("all_inlinks.csv")

# Only include pages on domain
data_mym <- data %>%
  filter(str_detect(Source, "makeyourmarkdigital.com")) %>%
  filter(str_detect(Destination, "makeyourmarkdigital.com"))

# Remove wp element urls
data_mym_excld_wp <- data_mym %>%
  filter(!str_detect(Destination, "wp"))


data_links <- data_mym_excld_wp %>%
  select(Source, Destination)

#
# #SKIP THIS PART IF ALREADY PREPARED data_nodes.csv
# #Create list of pages for export to csv
# data_nodes <- data_links %>%
#   pivot_longer(everything(), values_to = "Node") %>%
#   distinct(Node)
# 
# # Export to csv (Adding Group by hand)
# write_csv(data_nodes, "data_nodes.csv")
# 
# # Add groups by hand
# 
# # Import data_nodes with added Group column
#

#CONTINUE HERE

# Import data_nodes.csv
data_nodes <- read_csv("data_nodes.csv")

# Add sequential IDs to data_nodes
data_nodes <- data_nodes %>%
  mutate(ID = row_number() - 1)  # 0-based indexing

# Prepare data_links by mapping URLs to their numeric IDs
data_links <- data_links %>%
  left_join(data_nodes, by = c("Source" = "Node")) %>%
  left_join(data_nodes, by = c("Destination" = "Node"), suffix = c(".source", ".destination")) %>%
  select(Source = ID.source, Target = ID.destination) # Use the numeric IDs for Source and Target

# Plot with forceNetwork
forceNetwork(Links = data_links, Nodes = data_nodes,
             Source = "Source", Target = "Target",
             NodeID = "Node", Group = "Group",
             opacity = 0.8, linkDistance = 200, zoom = TRUE)
