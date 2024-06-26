# JAVA environmental variables setup
# https://azimuahamed.medium.com/java-environment-variables-setup-windows-11-58fe71e43b5e
# Restarting the PC is required

# Required packages

library(RSelenium)
library(dplyr)
library(rvest)
library(jsonlite)
library(readr)
library(tictoc)

#####urls2_3#####################################################################
# Activate firefox

urls2_3 <- list()
for (j in 2:3){
  rD <- rsDriver(browser="firefox",chromever = NULL, port=netstat::free_port(), verbose=F)
  remDr <- rD[["client"]]
  
  # navigate to page j
  remDr$navigate(paste0("https://www.99acres.com/property-in-kolkata-ffid-page", j))
  
  # Get all the urls in page j
  urls2_3[j] <- remDr$findElements(using = "xpath", "//*[@class='ellipsis']") |> 
    sapply(function(x){x$getElementAttribute("href")}[[1]]) %>% 
    list()
  remDr$closeWindow()
  rD$server$stop()
}


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

# Scrape the data in page 1

for (i in 1:length(unlist(urls2_3))){
  rD <- rsDriver(browser="firefox",chromever = NULL, port=netstat::free_port(), verbose=F)
  remDr <- rD[["client"]]
  remDr$navigate(unlist(urls2_3)[i])
  
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

housing_data2_3 <- tibble(
  price = Price,
  bhk = Bhk ,
  area_sqft = Area_sqft,
  latitude = Latitude ,
  longitude = Longitude ,
  top_facilities = Top_facilities,
  other_facilities = Other_facilities,
  locational_advantages = Locational_advantages,
  distance_to_locational_advantage = Distance_to_locational_advantage 
)
#########urls4_6########################################


# Activate firefox

urls4_6 <- list()
for (j in 4:6){
  rD <- rsDriver(browser="firefox",chromever = NULL, port=netstat::free_port(), verbose=F)
  remDr <- rD[["client"]]
  
  # navigate to page j
  remDr$navigate(paste0("https://www.99acres.com/property-in-kolkata-ffid-page", j))
  
  # Get all the urls in page j
  urls4_6[j] <- remDr$findElements(using = "xpath", "//*[@class='ellipsis']") |> 
    sapply(function(x){x$getElementAttribute("href")}[[1]]) %>% 
    list()
  remDr$closeWindow()
  rD$server$stop()
}


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

# Scrape the data in page 1

for (i in 1:length(unlist(urls4_6))){
  rD <- rsDriver(browser="firefox",chromever = NULL, port=netstat::free_port(), verbose=F)
  remDr <- rD[["client"]]
  remDr$navigate(unlist(urls4_6)[i])
  
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

housing_data4_6 <- tibble(
  price = Price[1:40],
  bhk = Bhk[1:40] ,
  area_sqft = Area_sqft[1:40],
  latitude = Latitude[1:40] ,
  longitude = Longitude[1:40] ,
  top_facilities = Top_facilities[1:40],
  other_facilities = Other_facilities[1:40],
  locational_advantages = Locational_advantages[1:40],
  distance_to_locational_advantage = Distance_to_locational_advantage[1:40]
)


###########urls7_9################
# Activate firefox

urls7_9 <- list()
for (j in 7:9){
  rD <- rsDriver(browser="firefox",chromever = NULL, port=netstat::free_port(), verbose=F)
  remDr <- rD[["client"]]
  
  # navigate to page j
  remDr$navigate(paste0("https://www.99acres.com/property-in-kolkata-ffid-page", j))
  
  # Get all the urls in page j
  urls7_9[j] <- remDr$findElements(using = "xpath", "//*[@class='ellipsis']") |> 
    sapply(function(x){x$getElementAttribute("href")}[[1]]) %>% 
    list()
  remDr$closeWindow()
  rD$server$stop()
}


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

# Scrape the data in page 1

for (i in 1:length(unlist(urls7_9))){
  rD <- rsDriver(browser="firefox",chromever = NULL, port=netstat::free_port(), verbose=F)
  remDr <- rD[["client"]]
  remDr$navigate(unlist(urls7_9)[i])
  
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

housing_data7_9 <- tibble(
  price = Price,
  bhk = Bhk ,
  area_sqft = Area_sqft,
  latitude = Latitude ,
  longitude = Longitude ,
  top_facilities = Top_facilities,
  other_facilities = Other_facilities,
  locational_advantages = Locational_advantages,
  distance_to_locational_advantage = Distance_to_locational_advantage 
)
