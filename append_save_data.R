library(tidyverse)
housing_data1 <- mget(paste0('housing_data_page', 1:25)) |> 
  bind_rows()

housing_data2 <- mget(paste0('housing_data_page', 26:28)) |> 
  bind_rows() |> 
  unnest_wider(c(1, 2),names_sep = "_") |> 
  select(c(1,3,5:11)) |> 
  mutate(latitude = as.numeric(latitude),
         longitude = as.numeric(longitude)) |> 
  rename(price = price_1,
         bhk = bhk_1)

housing_data <-  bind_rows(housing_data1, housing_data2)  
housing_data |>   
unnest_wider(c(1:3, 6:9),names_sep = "_") |> sapply(class)
  write.csv("housing_data.csv")

read_csv("housing_data.csv") -> csv

