# install.packages("RSelenium")
# install.packages("dplyr")

library(RSelenium)
library(dplyr)
library(rvest)
library(jsonlite)

# Method 1
# Install chromedriver 
# Documentation at https://cran.r-project.org/web/packages/RSelenium/RSelenium.pdf page 16

rD <- rsDriver(browser="firefox",chromever = NULL, port=netstat::free_port(), verbose=F)
remDr <- rD[["client"]]

# Method 2
# Run the following from terminal. Docker required.
# docker pull selenium/standalone-firefox
# docker run -d -p 4445:4444 selenium/standalone-firefox
# Run 
# remDr <- remoteDriver(
#   remoteServerAddr = "localhost",
#   port = 4445L,
#   browserName = "firefox"
# )
# remDr$open()

remDr$navigate("https://www.99acres.com/property-in-kolkata-ffid-page1")

urls <- remDr$findElements(using = "xpath", "//*[@class='ellipsis']") |> 
  sapply(function(x){x$getElementAttribute("href")}[[1]])

price <- c()
bhk <- c()
latitude <- c()
longitude <- c()

for (i in 1:2){
  rD <- rsDriver(browser="firefox",chromever = NULL, port=netstat::free_port(), verbose=F)
  remDr <- rD[["client"]]
  remDr$navigate(urls[i])
  
  
  price[i] <- remDr$findElements(using = "xpath", "//*[@class='list_header_semiBold configurationCards__configurationCardsHeading']") |> 
    sapply(function(x){x$getElementText()[[1]]})
  
  bhk[i] <- remDr$findElements(using = "xpath", "//*[@class='ellipsis list_header_semiBold configurationCards__configurationCardsSubHeading']") |> 
    sapply(function(x){x$getElementText()[[1]]})
 
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


