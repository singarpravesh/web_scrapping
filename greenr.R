# install.packages("remotes") # Uncomment if you do not have the 'remotes' package installed
remotes::install_github("sachit27/greenR", dependencies = TRUE)
library(greenR)

data <- get_osm_data("Kolkata, India")
green_areas_data <- data$green_areas
visualize_green_spaces(green_areas_data)


green_areas_data$osm_polygons %>% 
  select(landuse) %>% 
  group_by(landuse) %>% 
  summarise(n())

trees_data <- data$trees
trees_data$osm_points %>% 
  select(natural) %>% 
  group_by(natural) %>% 
  summarise(n())

visualize_green_spaces(trees_data)
