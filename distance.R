

library(osmdata)
library(sf)
library(tidyverse)
library(leaflet)


# 1. enlarge the bounding box to include districts beyond Kolkata and the same one that you get 
#    for 99acres.com
# 2. Query OSM for green spaces with the bounding box in 1.
# 3. Extract the relevant data.


# Define the bounding box for Kolkata
bbox <- getbb("Kolkata, India")

# Query OSM for green spaces
green_spaces <- opq(bbox = bbox) %>%
  add_osm_feature(key = 'leisure', value = 'park') %>%
  osmdata_sf()

# Extract the relevant data
parks <- green_spaces$osm_polygons

# Extract coordinates
parks_coords <- st_coordinates(parks)

# Create a leaflet map
leaflet() %>%
  addTiles() %>%
  addPolygons(data = parks, color = "green", weight = 1, fillColor = "green", fillOpacity = 0.5) %>%
  setView(lng = 88.3639, lat = 22.5726, zoom = 12)

# Save the data to a CSV file
parks_df <- as.data.frame(st_coordinates(parks))
write.csv(parks_df, "kolkata_green_spaces.csv", row.names = FALSE)


read.csv("housing_data.csv") -> house


install.packages("geosphere")
library(geosphere)

# Example coordinates (longitude, latitude)


house_data_sf <- housing_data %>% 
  na.omit() %>% 
  st_as_sf(coords = c("longitude", "latitude"), crs = 'WGS84') 

park_coordinates <- (parks) |> select(geometry) |> 
  slice(2) |> st_centroid() # Coordinates for the park

as_tibble(house_coordinates)[[1]][1,] |> as_vector()
# calculate the distance between park and the housing
distVincentySphere(as_tibble(park_coordinates)[[1]][1,] |> as_vector(), 
                   as_tibble(house_coordinates)[[1]][1,] |> as_vector())
