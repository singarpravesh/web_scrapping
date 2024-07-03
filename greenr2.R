# Install and load necessary packages
# install.packages(c("osmdata", "sf", "leaflet"))
library(osmdata)
library(sf)
library(leaflet)

# Define the name of the place
place_name <- "Kolkata, India"

# Query OpenStreetMap for the boundary of Kolkata
kolkata_boundary <- opq(place_name) %>%
  add_osm_feature(key = "boundary", value = "administrative") %>%
  add_osm_feature(key = "admin_level", value = "6") %>%
  osmdata_sf()

# Extract the boundary polygon
kolkata_boundary_lines <- kolkata_boundary$osm_lines

# If osm_multipolygons is empty, try osm_polygons
#if (nrow(kolkata_boundary_polygon) == 0) {
 # kolkata_boundary_polygon <- kolkata_boundary$osm_polygons
#}





# Create a leaflet map centered on Kolkata
map <- leaflet() %>%
  addTiles() %>%
  setView(lng = 88.3639, lat = 22.5726, zoom = 12)  # Coordinates for Kolkata

# Add points for each house
map <- map %>%
  addCircleMarkers(
    lng = housing_data$longitude,
    lat = housing_data$latitude,
    popup = paste("Price:", housing_data$price, "<br>",
                  "Size:", housing_data$area_sqft, "<br>",
                  "Bedrooms:", housing_data$bhk),
    radius = 5,
    color = "blue",
    fillOpacity = 0.5
  )

# Add green spaces to the map
map <- map %>%
  addPolygons(
    data = green_areas_data$osm_polygons,
    fillColor = "green",
    fillOpacity = 0.5,
    color = "green",
    weight = 1
  )

# Add Kolkata boundary to the map
map <- map %>%
  addPolylines(
    data = kolkata_boundary_lines,
    color = "red",
    weight = 3,
    dashArray = "5, 10",  # Make the line dashed
    opacity = 1
  )

# Print the map
map
