library(future)
library(RSelenium)
library(netstat)
library(rvest)
library(jsonlite)
library(dplyr)
library(tictoc)

plan(multisession)

# Define the URLs (example)
urls

# Initialize vectors/lists to store the results
Price <- vector("list", length(urls[-c(9,23)]))
Bhk <- vector("list", length(urls[-c(9,23)]))
Area_sqft <- vector("list", length(urls[-c(9,23)]))
Latitude <- vector("numeric", length(urls[-c(9,23)]))
Longitude <- vector("numeric", length(urls[-c(9,23)]))
Top_facilities <- vector("list", length(urls[-c(9,23)]))
Other_facilities <- vector("list", length(urls[-c(9,23)]))
Locational_advantages <- vector("list", length(urls[-c(9,23)]))
Distance_to_locational_advantage <- vector("list", length(urls[-c(9,23)]))

# List to store futures
futures <- list()

tic("Time")
for (i in 1:length(urls[-c(9,23)])) {
  futures[[i]] <- future({
    rD <- rsDriver(browser = "firefox", chromever = NULL, port = netstat::free_port(), verbose = F, check = F)
    remDr <- rD[["client"]]
    remDr$navigate(urls[-c(9,23)][i])
    
    # Click the ok button
    remDr$findElement(using = "css", value = ".ReraDisclaimer__topDisclaimer > div:nth-child(1) > div:nth-child(2) > button:nth-child(1)")$clickElement()
    
    # Data for price
    Price <- remDr$findElements(using = "xpath", "//*[@class='list_header_semiBold configurationCards__configurationCardsHeading']") |> 
      sapply(function(x) { x$getElementText()[[1]] })
    
    # BHK data
    Bhk <- remDr$findElements(using = "xpath", "//*[@class='ellipsis list_header_semiBold configurationCards__configurationCardsSubHeading']") |> 
      sapply(function(x) { x$getElementText()[[1]] })
    
    # Area data
    Area_sqft <- remDr$findElements(using = "xpath", "//*[@class='caption_subdued_medium configurationCards__cardAreaSubHeadingOne']") |> 
      sapply(function(x) { x$getElementText()[[1]] }) %>% 
      list()
    
    # Coordinates of the property
    html <- remDr$getPageSource()[[1]]
    json_ld_script <- read_html(html) |> 
      html_nodes('script[type="application/ld+json"]')
    json_ld_data <- lapply(json_ld_script, function(x) {
      json_str <- html_text(x)
      fromJSON(json_str)
    })
    Latitude <- json_ld_data[[3]]$geo$latitude
    Longitude <- json_ld_data[[3]]$geo$longitude
    
    # Top facilities
    Top_facilities <- read_html(html) |> 
      html_nodes('div[class="UniquesFacilities__xidFacilitiesCard"]') %>% 
      html_text() %>% list()
    
    # Other facilities
    remDr$executeScript("window.scrollTo(0,1700);") # Need to scroll to the specific section
    # Scroll to the specific section
    #elem <- remDr$findElement(using = 'css', value = '.UniquesFacilities__pageHeadingWrapper > h2:nth-child(1)')
    #remDr$executeScript("arguments[0].scrollIntoView(true);", list(elem))
    
    remDr$setTimeout(type = "implicit", milliseconds = 20000) # Need to wait to load the page in the remote driver
    remDr$findElement(using = "css", value = ".UniquesFacilities__pageHeadingWrapper > a:nth-child(2)")$clickElement() # Click on the View all button
    html_page <- remDr$getPageSource()[[1]] # get the html content of the pop up page after click
    Other_facilities <- read_html(html_page) |> 
      html_nodes('div[class="body_med"]') %>% 
      html_text() %>% list()
    
    # Locational advantages (do the same as for 'other failities' above)
    remDr$executeScript("window.scrollTo(0,2100);")
    remDr$setTimeout(type = "implicit", milliseconds = 20000)
    remDr$findElement(using = "css", value = ".OrderComponent__leftSection > div:nth-child(5) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > a:nth-child(2)")$clickElement()
    html_page <- remDr$getPageSource()[[1]]
    Locational_advantages <- read_html(html_page) |> 
      html_nodes('div[class="list_header_semiBold spacer2 ellipsis"]') %>% 
      html_text() %>% list()
    
    # Distance to locational advantages as specified above
    Distance_to_locational_advantage <- read_html(html_page) |> 
      html_nodes('div[class="caption_subdued_medium ellipsis"]') %>% 
      html_text() %>% list()
    
    # Close the remote firefox window
    remDr$closeWindow()
    
    # Remove the objects that can clutter the environment
    remove(html)
    remove(json_ld_data)
    remove(json_ld_script)
    remove(rD)
    remove(remDr)
    remove(html_page)
    
    list(
      Price = Price,
      Bhk = Bhk,
      Area_sqft = Area_sqft,
      Latitude = Latitude,
      Longitude = Longitude,
      Top_facilities = Top_facilities,
      Other_facilities = Other_facilities,
      Locational_advantages = Locational_advantages,
      Distance_to_locational_advantage = Distance_to_locational_advantage
    )
  }, seed = TRUE) #Adding seed = TRUE: By including seed = TRUE in the future function call, you ensure that the random numbers generated within each future are parallel-safe and reproducible. This uses the L'Ecuyer-CMRG method for generating random numbers.
}

# Retrieve the results from the futures
for (i in 1:length(futures)) {
  result <- value(futures[[i]])
  Price[[i]] <- result$Price
  Bhk[[i]] <- result$Bhk
  Area_sqft[[i]] <- result$Area_sqft
  Latitude[i] <- result$Latitude
  Longitude[i] <- result$Longitude
  Top_facilities[[i]] <- result$Top_facilities
  Other_facilities[[i]] <- result$Other_facilities
  Locational_advantages[[i]] <- result$Locational_advantages
  Distance_to_locational_advantage[[i]] <- result$Distance_to_locational_advantage
}

toc()