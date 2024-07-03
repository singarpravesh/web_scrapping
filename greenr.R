# install.packages("remotes") # Uncomment if you do not have the 'remotes' package installed
# remotes::install_github("sachit27/greenR", dependencies = TRUE)
library(greenR)
library(leaflet)

data <- get_osm_data("Kolkata, India")

green_areas_data <- data$green_areas

green_areas_data$osm_polygons 
  ggplot()+
    geom_sf(data = data$green_areas$osm_polygons["geometry"])+
    geom_sf(data = green_areas_data$osm_polygons, fill = "green")+
    geom_sf(data = data$trees$osm_points, fill = "red")

leaflet(green_areas_data) %>% addPolygons(data = green_areas_data$osm_polygons, 
                             fillColor = "green", fillOpacity = 0.7, color = "black", 
                             weight = 1, group = "Green Spaces")
  
visualize_green_spaces(green_areas_data)


green_areas_data$osm_polygons %>% 
  select(landuse) %>% 
  group_by(landuse) %>% 
  summarise(n()) %>% 
  slice(4) %>% 
  leaflet() %>% 
  addTiles() %>% 
  addPolygons(fillColor = "green", fillOpacity = 0.7, color = "black", 
              weight = 1, group = "Green Spaces") 

# identify the green space variable and its distribution
trees_data <- data$trees
trees_data$osm_points %>% 
  select(natural) %>% 
  group_by(natural) %>% 
  summarise(n())



kolkata_boundary <- opq("Kolkata, India") %>%
  add_osm_feature(key = "boundary", value = "administrative") %>%
  osmdata_sf()
kolkata_boundary <- kolkata_boundary$osm_multipolygons %>% filter(name == "Kolkata")
# overlay housing data and green spaces data
leaflet() %>%
  addTiles() %>%
  setView(lng = 88.3639, lat = 22.5726, zoom = 12) %>% 
  addCircleMarkers(
    lng = na.omit(housing_data$longitude),
    lat = na.omit(housing_data$latitude),
    popup = paste("Price:", housing_data$price, "<br>",
                  "Size:", housing_data$area_sqft, "<br>",
                  "Bedrooms:", housing_data$bhk),
    popupOptions = "interactive",
    radius = 5,
    color = "red",
    fillOpacity = 0.5
  ) %>% 
    addPolygons(data = green_areas_data$osm_polygons, fillColor = "green", fillOpacity = 0.7, color = "black", 
              weight = 1, group = "Green Spaces") %>% 
  addPolygons(data = kolkata_boundary$geometry, fill = "yellow")
  


