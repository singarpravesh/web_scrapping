library(tidyverse)
housing_data <- rows_append(housing_data_page1,
                            housing_data_page2) |> 
  rows_append(housing_data_page3) |> 
  rows_append(housing_data_page4) |> 
  rows_append(housing_data_page5) |> 
  rows_append(housing_data_page6) |> 
  rows_append(housing_data_page7)

mget(paste0('housing_data_page', 1:21)) |> 
  bind_rows() -> housing_data
          
housing_data |> 
  unnest_wider(c(1:3, 6:9),names_sep = "_") |> 
  write.csv("housing_data.csv")

read_csv("housing_data.csv") -> csv

