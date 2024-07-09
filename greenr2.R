# Install and load necessary packages
# install.packages(c("osmdata", "sf", "leaflet"))
library(osmdata)
library(sf)
library(leaflet)

# Define the name of the place
kolkata <- "Kolkata, India"


# Query OpenStreetMap for the boundary of Kolkata
kolkata_boundary <- opq(kolkata) %>%
  add_osm_feature(key = "boundary", value = "administrative") %>%
  add_osm_feature(key = "admin_level", value = "7") %>%
  osmdata_sf()

kolkata_green_spaces <- opq(kolkata) |> 
  add_osm_feature(key = "leisure", value = 'park') |> 
  osmdata_sf()


# Extract the boundary polygon
kolkata_boundary_lines <- kolkata_boundary$osm_lines
kolkata_green_spaces_polygons <- kolkata_green_spaces$osm_polygons

# Ensure both layers have the same CRS
kolkata_green_spaces_polygons <- st_transform(kolkata_green_spaces_polygons, st_crs(kolkata_boundary_lines))

# Perform spatial intersection
polygons_within_boundary <- st_intersection(kolkata_green_spaces_polygons, kolkata_boundary_lines)

ggplot() +
  geom_sf(data = kolkata_green_spaces_polygons, fill = NA, color = "black") +
  geom_sf(data = polygons_within_boundary, fill = "blue", color = "white") +
  theme_minimal()

# merge data
 library(sf) 

# If osm_multipolygons is empty, try osm_polygons
#if (nrow(kolkata_boundary_polygon) == 0) {
 # kolkata_boundary_polygon <- kolkata_boundary$osm_polygons
#}

###############
# https://rspatialdata.github.io/osm.html
# using the ggmap package
#library(ggmap)

ggplot()+
  geom_sf(data = kolkata_green_spaces_polygons, fill = "green")+
  geom_sf(data = kolkata_boundary_lines, fill = "red")
  

