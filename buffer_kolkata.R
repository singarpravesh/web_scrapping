library(osmdata)
library(sf)
library(ggplot2)
library(tidyverse)

# Define the bounding box for Kolkata
kolkata_bbox <- getbb("Kolkata, India")

# Get the boundary of Kolkata
boundary <- opq(bbox = kolkata_bbox) %>%
  add_osm_feature(key = "boundary", value = "administrative") %>%
  osmdata_sf() 
kolkata_boundary <-  boundary$osm_multipolygons |> filter(name %in% c('Howrah', 'Kolkata', 'North 24 Parganas',
                                                                      'South 24 Parganas', 'Haora')) |> 
  filter(admin_level == 5)

# Extract green spaces in Kolkata
kolkata_green_spaces <- opq(bbox = kolkata_bbox) %>%
  add_osm_feature(key = "landuse", 
                  value = c("forest", "grass",  
                            "meadow", "recreation_ground", 
                            "village_green")) %>%
  osmdata_sf() 



# Get the boundary of Kolkata_buffer
boundary <- opq(bbox = kolkata_buffer_bbox) %>%
  add_osm_feature(key = "boundary", value = "administrative") %>%
  osmdata_sf() 
kolkata_boundary <-  boundary$osm_multipolygons |> filter(name %in% c('Howrah', 'Kolkata', 'North 24 Parganas',
                                                                      'South 24 Parganas', 'Haora')) |> 
  filter(admin_level == 5) 

# Extract green spaces in Kolkata_buffer
kolkata_landuse <- opq(bbox = kolkata_buffer_bbox) %>%
  add_osm_features(features = list(
    "landuse" = "forest",
    "landuse" = "grass",
    "landuse" = "meadow",
    "landuse" = "recreation_ground",
    "landuse" = "village_green"
  )) |> 
  osmdata_sf() 

kolkata_leisure <- opq(bbox = kolkata_buffer_bbox) %>%
  add_osm_feature(key = "leisure",
                  value = c("park", "water_park", "swimming_area",
                            "playground", "nature_reserve", "garden",)
  ) |> 
  osmdata_sf()

kolkata_green_spaces <- c(kolkata_landuse,
                          kolkata_leisure)


# Calculate the centroid of Kolkata
kolkata_centroid <- st_centroid(filter(kolkata_boundary, name == "Kolkata"))

# Create a 20 km buffer around the centroid
kolkata_buffer <- st_buffer(kolkata_centroid, dist = 20000)

# Calculate the bounding box of the buffer
kolkata_buffer_bbox <- st_bbox(kolkata_buffer)

# Extend the bounding box by 10 km
kolkata_bbox_extended <- c(kolkata_buffer_bbox[1] - 0.006, 
                           kolkata_buffer_bbox[2] - 0.006, 
                           kolkata_buffer_bbox[3] + 0.006, 
                           kolkata_buffer_bbox[4] + 0.006)
# Housing data
housing_data_sf <-  housing_data %>% 
  na.omit() %>% 
  st_as_sf(coords = c("longitude", "latitude"), crs = st_crs(kolkata_buffer)) 
# Plot the results
ggplot() +
  geom_sf(data = kolkata_boundary, fill = "lightgrey") +
  geom_sf(data = kolkata_centroid, col = "red", size = 2) +
  geom_sf(data = kolkata_buffer, fill = NA, color = "red") +
  geom_sf(data = kolkata_green_spaces$osm_polygons, fill = 'green')+
  geom_sf(data = housing_data_sf$geometry, col = "blue", alpha = 0.5) +
  coord_sf(xlim = kolkata_bbox_extended[c(1,3)], 
           ylim = kolkata_bbox_extended[c(2,4)]) 

# Extract housing data within the buffer area
housing_data_buffer <- st_intersection(housing_data_sf, kolkata_buffer)

# Plot the updated map
ggplot() +
  geom_sf(data = kolkata_boundary, fill = "lightgrey", lwd = 1) +
  geom_sf(data = kolkata_centroid, col = "red", size = 2) +
  geom_sf(data = kolkata_buffer, fill = NA, color = "red") +
  geom_sf(data = kolkata_green_spaces$osm_polygons, fill = 'green') +
  geom_sf(data = housing_data_buffer$geometry, col = "blue", alpha = 0.5) +
  coord_sf(xlim = kolkata_bbox_extended[c(1,3)], 
           ylim = kolkata_bbox_extended[c(2,4)])

kolkata_green_spaces$osm_polygons |> 
  mutate(greens = if_else(
    name == "<na>", 0, 1)
  ) |> group_by(greens) |> summarise(n())
st_join(housing_data_buffer, kolkata_green_spaces$osm_polygons, left = TRUE) |> names() 
  ggplot()+
  geom_sf( fill = "lightgrey") +
  geom_sf(aes())
# Data within the buffer of 20 km
housing_data_buffer
kolkata_green_spaces$osm_polygons




opq(bbox = kolkata_buffer_bbox) %>%
  add_osm_features(features = list(
    "landuse" = "forest",
    "landuse" = "grass",
    "landuse" = "meadow",
    "landuse" = "recreation_ground",
    "landuse" = "village_green"
  )) |> 
  
  osmdata_sf() -> a
  opq(bbox = kolkata_buffer_bbox) %>%
    add_osm_feature(key = "leisure",
                    value = "park"
    ) |> 
    osmdata_sf() -> b
  
  c(a,b) -> b1
names(b1$osm_polygons)
b1$osm_polygons$leisure |> table()
