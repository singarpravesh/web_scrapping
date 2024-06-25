library(RSelenium)
library(dplyr)
library(rvest)
library(jsonlite)

urls

# latitude


Other_facilities <- list()

for (i in 1:2){
  rD <- rsDriver(browser="firefox",chromever = NULL, port=netstat::free_port(), verbose=F)
  remDr <- rD[["client"]]
  remDr$navigate(urls[i])
  
  remDr$findElement(using = "css", value = ".UniquesFacilities__pageHeadingWrapper > a:nth-child(2)")$clickElement()
  
  html_page <- remDr$getPageSource()[[1]]
  Other_facilities[i] <- read_html(html_page) |> 
    html_nodes('div[class="body_med"]') %>% 
    html_text() %>% list()
  
  
  remDr$closeWindow()
  

  remove(html_page)
  remove(rD)
  remove(remDr)
}
