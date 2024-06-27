library(RSelenium)
library(rvest)
library(jsonlite)
library(dplyr)
library(tictoc)
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
Locational_advantages <- list()
Distance_to_locational_advantage <- list()

tic("Time")
for (i in 1:length(urls)){
# Initialize RSelenium
rD <- rsDriver(browser="firefox", chromever = NULL, port=netstat::free_port(), verbose=F)
remDr <- rD[["client"]]

# Navigate to the URL
remDr$navigate(urls[i])

# Helper function to check if element exists
element_exists <- function(using, value) {
  length(remDr$findElements(using = using, value = value)) > 0
}

# Click the OK button if it exists
if (element_exists("css", ".ReraDisclaimer__topDisclaimer > div:nth-child(1) > div:nth-child(2) > button:nth-child(1)")) {
  remDr$findElement(using = "css", value = ".ReraDisclaimer__topDisclaimer > div:nth-child(1) > div:nth-child(2) > button:nth-child(1)")$clickElement()
} else {
  message("OK button not found or could not be clicked")
}

# Data for price
if (element_exists("xpath", "//*[@class='list_header_semiBold configurationCards__configurationCardsHeading']")) {
  Price[i] <- remDr$findElements(using = "xpath", "//*[@class='list_header_semiBold configurationCards__configurationCardsHeading']") |> 
    sapply(function(x){x$getElementText()[[1]]})
} else {
  Price[i] <- NA
}

# BHK data
if (element_exists("xpath", "//*[@class='ellipsis list_header_semiBold configurationCards__configurationCardsSubHeading']")) {
  Bhk[i] <- remDr$findElements(using = "xpath", "//*[@class='ellipsis list_header_semiBold configurationCards__configurationCardsSubHeading']") |> 
    sapply(function(x){x$getElementText()[[1]]})
} else {
  Bhk[i] <- NA
}

# Area data
if (element_exists("xpath", "//*[@class='caption_subdued_medium configurationCards__cardAreaSubHeadingOne']")) {
  Area_sqft[i] <- remDr$findElements(using = "xpath", "//*[@class='caption_subdued_medium configurationCards__cardAreaSubHeadingOne']") |> 
    sapply(function(x){x$getElementText()[[1]]}) %>% 
    list()
} else {
  Area_sqft[i] <- NA
}

# Coordinates of the property
tryCatch({
  html <- remDr$getPageSource()[[1]]
  json_ld_script <- read_html(html) |> 
    html_nodes('script[type="application/ld+json"]')
  json_ld_data <- lapply(json_ld_script, function(x) {
    json_str <- html_text(x)
    fromJSON(json_str)
  })
  Latitude[i] <- json_ld_data[[3]]$geo$latitude
  Longitude[i] <- json_ld_data[[3]]$geo$longitude
}, error = function(e) {
  message("Coordinates not found: ", e$message)
})

# Top facilities
tryCatch({
  Top_facilities[i] <- read_html(html) |> 
    html_nodes('div[class="UniquesFacilities__xidFacilitiesCard"]') %>% 
    html_text() %>% list()
}, error = function(e) {
  message("Top facilities not found: ", e$message)
})

# Other facilities
tryCatch({
  remDr$executeScript("window.scrollTo(0,1600);") # Scroll to the specific section
  remDr$setTimeout(type = "implicit", milliseconds = 20000) # Wait to load the page
  if (element_exists("css", ".UniquesFacilities__pageHeadingWrapper > a:nth-child(2)")) {
    remDr$findElement(using = "css", value = ".UniquesFacilities__pageHeadingWrapper > a:nth-child(2)")$clickElement()
    html_page <- remDr$getPageSource()[[1]] # Get the HTML content of the pop up page after click
    
    Other_facilities[i] <- read_html(html_page) |> 
      html_nodes('div[class="body_med"]') %>% 
      html_text() %>% list()
  } else {
    Other_facilities[i] <- NA
  }
}, error = function(e) {
  message("Other facilities not found: ", e$message)
})

# Locational advantages
tryCatch({
  remDr$executeScript("window.scrollTo(0,2100);") # Scroll to the specific section
  remDr$setTimeout(type = "implicit", milliseconds = 20000) # Wait to load the page
  if (element_exists("css", ".OrderComponent__leftSection > div:nth-child(5) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > a:nth-child(2)")) {
    remDr$findElement(using = "css", value = ".OrderComponent__leftSection > div:nth-child(5) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > a:nth-child(2)")$clickElement()
    html_page <- remDr$getPageSource()[[1]]
    
    Locational_advantages[i] <- read_html(html_page) |> 
      html_nodes('div[class="list_header_semiBold spacer2 ellipsis"]') %>% 
      html_text() %>% list()
  } else {
    Locational_advantages[i] <- NA
  }
  
  if (!is.na(Locational_advantages[i])){  
    Distance_to_locational_advantage[i]<- read_html(html_page) |> 
      html_nodes('div[class="caption_subdued_medium ellipsis"]') %>% 
      html_text() %>% list()
  } else {
    Distance_to_locational_advantage[i] <- NA
  }
}, error = function(e) {
  message("Locational advantages not found: ", e$message)
})

remDr$closeWindow()
rD$server$stop()
# Remove the objects that can clutter the environment
remove(html)
remove(json_ld_data)
remove(json_ld_script)
remove(html_page)
remove(rD)
remove(remDr)
gc()
}
toc()