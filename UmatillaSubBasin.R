library(RSQLite)
library(DBI)
library(tidyverse)
library(viridis)
library(patchwork)
library(ggplot2)

# Create new database in RSQLite

UmatillaSubBasin_db <-dbConnect(RSQLite::SQLite(), "UmatillaSubBasin.db")

# Create reaches table with reach_name as primary key

dbExecute(UmatillaSubBasin_db, "CREATE TABLE reaches (
          reach_name,
          river_name,
          lat,
          long,
          elevation_m,
          temp_rank,
          PRIMARY KEY (reach_name)
          );")

# Load reaches data from csv into reaches table

reaches <- read.csv("../Final Project/data/reaches.csv", 
                    stringsAsFactors = FALSE)

names(reaches)
names(reaches)[1]<- "reach_name"

# Import data into the reaches table, which stores information on all of the
# reaches I have information on

dbWriteTable(UmatillaSubBasin_db, "reaches", reaches, append = TRUE)

# Ran a query to make sure it was reading the data correctly

dbGetQuery(UmatillaSubBasin_db, "SELECT * FROM reaches LIMIT 10;")

# Create flows data with reach_name as foreign key

dbExecute(UmatillaSubBasin_db, "CREATE TABLE flows (
          reach_name,
          reach_length_m,
          drainage_ha,
          currentflow_cfs,
          lowflow_2040_cfs,
          lowflow_2080_cfs,
          system_id,
          FOREIGN KEY(reach_name) REFERENCES reaches(reach_name)
          );")

# Load flows data from csv into flows table

flows <- read.csv("../Final Project/data/flows.csv", 
                  stringsAsFactors = FALSE)

# Import data into the flows table, which stores information on only the reaches
# where temperature was sampled

dbWriteTable(UmatillaSubBasin_db, "flows", flows, append = TRUE)

# Run a query to make sure it is reading the data correctly

dbGetQuery(UmatillaSubBasin_db, "SELECT * FROM flows LIMIT 10;")

# Create a plot to show the distribution of stream temperature across the 
# elevation gradient among sampled reaches

reaches %>%
  ggplot() +
  geom_point(aes(y = elevation_m, x = temp_rank, color = river_name)) +
  theme_minimal() +
  labs(fill = 'Total Upstream Drainage Area (sqKm)',
       y = 'Elevation (m)', 
       x = 'Temperature (m)', 
       color = 'River') +
  theme(legend.position = "bottom")

# Create a map of the reaches and color code by the agricultural intensity
# Seems to be mapping correctly, but I can't it to color code by system_id

flows %>%
  left_join(reaches, by = "reach_name") %>%
  ggplot(aes(x = long, y = lat, color = system_id)) +
  geom_point() +
  theme_minimal() +
  labs( fill = 'Agricultural Intensity',
        x = 'Decimal Degrees', 
        y = 'Decimal Degrees',
        color = 'Agricultural Intensity') +
  theme_minimal()






