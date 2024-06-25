library(RSelenium)
library(dplyr)
library(rvest)
library(jsonlite)

urls

# latitude


Top_facilities <- list()
Other_facilities <- list()

for (i in 1:2){
  rD <- rsDriver(browser="firefox",chromever = NULL, port=netstat::free_port(), verbose=F)
  remDr <- rD[["client"]]
  remDr$navigate(urls[i])
  
  html_page_main <- remDr$getPageSource()[[1]]
  
  Top_facilities[i] <- read_html(html_page_main) |> 
    html_nodes('div[class="UniquesFacilities__xidFacilitiesCard"]') %>% 
    html_text()
  
  remDr$findElement(using = "css", value = ".UniquesFacilities__pageHeadingWrapper > a:nth-child(2)")$clickElement()
                       
  html_page <- remDr$getPageSource()[[1]]
  Other_facilities[i] <- read_html(html_page) |> 
    html_nodes('div[class="body_med"]') %>% 
    html_text()
  
  
  remDr$closeWindow()
  remove(html_page_main)
  remove(html_page)
  remove(rD)
  remove(remDr)
}

