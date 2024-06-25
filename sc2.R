library(RSelenium)
library(dplyr)
library(rvest)
library(jsonlite)

urls

# latitude


Facilities <- c()

for (i in 1:2){
  rD <- rsDriver(browser="firefox",chromever = NULL, port=netstat::free_port(), verbose=F)
  remDr <- rD[["client"]]
  remDr$navigate(urls[1])

  html <- remDr$getPageSource()[[1]]
  json_ld_script <- read_html(html) |> 
  html_nodes('script[type="application/ld+json"]')
  json_ld_data <- lapply(json_ld_script, function(x) {
  json_str <- html_text(x)
  fromJSON(json_str)
  })
  
  latitude[i] <- json_ld_data[[3]]$geo$latitude
  longitude[i] <- json_ld_data[[3]]$geo$longitude
  remDr$closeWindow()

  remove(html)
  remove(json_ld_data)
  remove(json_ld_script)
  remove(rD)
  remove(remDr)
}

