library(RSelenium)
library(dplyr)
library(rvest)
library(jsonlite)

urls

# latitude


Top_facilities <- list()


for (i in 1:2){
  rD <- rsDriver(browser="firefox",chromever = NULL, port=netstat::free_port(), verbose=F)
  remDr <- rD[["client"]]
  remDr$navigate(urls[i])
  
  html_page_main <- remDr$getPageSource()[[1]]
  
  Top_facilities[i] <- read_html(html_page_main) |> 
    html_nodes('div[class="UniquesFacilities__xidFacilitiesCard"]') %>% 
    html_text() %>% list()
  
 
  
  remDr$closeWindow()
  
  remove(html_page_main)
  remove(rD)
  remove(remDr)
}

