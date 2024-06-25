# JAVA environmental variables setup
# https://azimuahamed.medium.com/java-environment-variables-setup-windows-11-58fe71e43b5e
# Restaring the PC is required

# Required packages

library(RSelenium)
library(dplyr)
library(rvest)
library(jsonlite)
library(readr)

##########################################################################
# Activate firefox
rD <- rsDriver(browser="firefox",chromever = NULL, port=netstat::free_port(), verbose=F)
remDr <- rD[["client"]]

# navigate to page 1
remDr$navigate("https://www.99acres.com/property-in-kolkata-ffid-page1")

# Get all the urls in page 1
urls <- remDr$findElements(using = "xpath", "//*[@class='ellipsis']") |> 
  sapply(function(x){x$getElementAttribute("href")}[[1]])

############################################################################

# Initalise the variables
Price <- c()

# Structural variables 
Bhk <- c() # No of rooms (1,2,3,4)
Area_sqft <- list() 

# Locational variables
Latitude <- c()
Longitude <- c()
Top_facilities <- list()
Other_facilities <- list()


# Scrape the data in page 1
for (i in 1:2){
  rD <- rsDriver(browser="firefox",chromever = NULL, port=netstat::free_port(), verbose=F)
  remDr <- rD[["client"]]
  remDr$navigate(urls[i])
  
  remDr$findElement(using = "css", value = ".ReraDisclaimer__topDisclaimer > div:nth-child(1) > div:nth-child(2) > button:nth-child(1)")$clickElement()
  
  Price[i] <- remDr$findElements(using = "xpath", "//*[@class='list_header_semiBold configurationCards__configurationCardsHeading']") |> 
    sapply(function(x){x$getElementText()[[1]]})
  
  Bhk[i] <- remDr$findElements(using = "xpath", "//*[@class='ellipsis list_header_semiBold configurationCards__configurationCardsSubHeading']") |> 
    sapply(function(x){x$getElementText()[[1]]})
 
  Area_sqft[i] <- remDr$findElements(using = "xpath", "//*[@class='caption_subdued_medium configurationCards__cardAreaSubHeadingOne']") |> 
    sapply(function(x){x$getElementText()[[1]]})
  
  html <- remDr$getPageSource()[[1]]
  json_ld_script <- read_html(html) |> 
    html_nodes('script[type="application/ld+json"]')
  json_ld_data <- lapply(json_ld_script, function(x) {
    json_str <- html_text(x)
    fromJSON(json_str)
  })
  
  Latitude[i] <- json_ld_data[[3]]$geo$latitude
  Longitude[i] <- json_ld_data[[3]]$geo$longitude
 
  Top_facilities[i] <- read_html(html) |> 
    html_nodes('div[class="UniquesFacilities__xidFacilitiesCard"]') %>% 
    html_text() %>% list()
  
  remDr$executeScript("window.scrollTo(0,1400);")
  remDr$setTimeout(type = "implicit", milliseconds = 2000)
  remDr$findElement(using = "css", value = ".UniquesFacilities__pageHeadingWrapper > a:nth-child(2)")$clickElement()
  html_page <- remDr$getPageSource()[[1]]
  Other_facilities[i] <- read_html(html_page) |> 
    html_nodes('div[class="body_med"]') %>% 
    html_text() %>% list()
  
  remDr$executeScript("window.scrollTo(0,1700);")
  remDr$setTimeout(type = "implicit", milliseconds = 2000)
  remDr$findElement(using = "css", value = ".OrderComponent__leftSection > div:nth-child(5) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > a:nth-child(2)")$clickElement()
  html_page <- remDr$getPageSource()[[1]]
  Locational_advantages[i] <- read_html(html_page) |> 
    html_nodes('div[class="list_header_semiBold spacer2 ellipsis"]') %>% 
    html_text() %>% list()
  
  Distance_to_locational_advantage[i] <- read_html(html_page) |> 
    html_nodes('div[class="caption_subdued_medium ellipsis"]') %>% 
    html_text() %>% list()
  
  remDr$closeWindow()
  
  remove(html)
  remove(json_ld_data)
  remove(json_ld_script)
  remove(rD)
  remove(remDr)
  remove(html_page)
  }

# Data frame

house_data <- tibble(price = Price,
                     bhk = Bhk,
                     area_sqft = Area_sqft,
                     top_facilities = Top_facilities,
                     other_facilities = Other_facilities,
                     latitude = round(as.numeric(Latitude), 8),
                     longitude = round(as.numeric(Longitude), 8)) |> 
  tidyr::separate_wider_delim(cols = price, delim = "-",
                                             names = c("price_min", "price_max"))
