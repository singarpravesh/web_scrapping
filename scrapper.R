

# Activate firefox
urls <- c()


rD <- rsDriver(browser="firefox",chromever = NULL, port=netstat::free_port(), verbose=F)
 remDr <- rD[["client"]]
# navigate to page 6
remDr$navigate("https://www.99acres.com/property-in-kolkata-ffid-page-26")

# Get all the urls in page 4
urls <- remDr$findElements(using = "xpath", "//*[@class='tupleNew__propertyHeading ellipsis']") |> 
  sapply(function(x){x$getElementAttribute("href")}[[1]]) 

remDr$closeWindow()

rD$server$stop()

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
  remDr$setTimeout(type = "implicit", milliseconds = 20000) # Wait to load the page
  remDr$setTimeout(type = "implicit", milliseconds = 20000) # Wait to load the page
  remDr$setTimeout(type = "implicit", milliseconds = 20000) # Wait to load the page
  
  # Helper function to check if element exists
  element_exists <- function(using, value) {
    length(remDr$findElements(using = using, value = value)) > 0
  }
  
  # Click the OK button if it exists
  #if (element_exists("css", ".ReraDisclaimer__topDisclaimer > div:nth-child(1) > div:nth-child(2) > button:nth-child(1)")) {
  #  remDr$findElement(using = "css", value = ".ReraDisclaimer__topDisclaimer > div:nth-child(1) > div:nth-child(2) > button:nth-child(1)")$clickElement()
#  } else {
#    message("OK button not found or could not be clicked")
 # }
  
  # Data for price
  if (element_exists("xpath", "//*[@class='component__pdPropValue']")) {
    Price[i] <- remDr$findElements(using = "xpath", "//*[@class='component__pdPropValue']") |> 
      sapply(function(x){x$getElementText()[[1]]}) |> list()
  } else {
    Price[i] <- NA
  }
  
  # BHK data
  if (element_exists("xpath", "//*[@class='component__pdPropDetail2Heading']")) {
    Bhk[i] <- remDr$findElements(using = "xpath", "//*[@class='component__pdPropDetail2Heading']") |> 
      sapply(function(x){x$getElementText()[[1]]}) |> list()
  } else {
    Bhk[i] <- NA
  }
  
  # Area data
  if (element_exists("xpath", "//*[@class=' component__details component__details2']")) {
    Area_sqft[i] <- remDr$findElements(using = "xpath", "//*[@class=' component__details component__details2']") |> 
      sapply(function(x){x$getElementText()[[1]]}) 
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
    Latitude[i] <- json_ld_data[[1]]$geo$latitude[1]
    Longitude[i] <- json_ld_data[[1]]$geo$longitude[1]
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
    remDr$executeScript("window.scrollTo(0,1200);") # Scroll to the specific section
    remDr$setTimeout(type = "implicit", milliseconds = 21000) # Wait to load the page
    if (element_exists("css", "#features > li:nth-child(1) > div:nth-child(2)")) {
      remDr$findElement(using = "css", value = "#features > li:nth-child(1) > div:nth-child(2)")
      html_page <- remDr$getPageSource()[[1]] # Get the HTML content of the pop up page after click
      
      Other_facilities[i] <- read_html(html_page) |> 
        html_nodes('div[class="#features > li:nth-child(1) > div:nth-child(2)"]') %>% 
        html_text() %>% list()
    } else {
      Other_facilities[i] <- NA
    }
  }, error = function(e) {
    message("Other facilities not found: ", e$message)
  })
  
  # Locational advantages
  tryCatch({
    remDr$executeScript("window.scrollTo(0,700);") # Scroll to the specific section
    remDr$setTimeout(type = "implicit", milliseconds = 20000) # Wait to load the page
    if (element_exists("css", "#LANDMARK_VIEW_ALL")) {
      remDr$findElement(using = "css", value = "#LANDMARK_VIEW_ALL")$clickElement()
      remDr$executeScript("window.scrollTo(0,700);") # Scroll to the specific section
      html_page <- remDr$getPageSource()[[1]]
        La1 <- read_html(html_page) |> 
        html_nodes('div[class="RoadDistanceBtmSheet__itemName"]') %>% 
        html_text() %>% list()
  } else {
      La1 <- NA
  }
    ### Next location
    
    if (element_exists("css", "i.pageComponent")) {
      remDr$findElement(using = "css", value = "i.pageComponent")$clickElement()
      remDr$findElement(using = "css", value = "#LANDMARK_VIEW_ALL")$clickElement()
      remDr$findElement(using = "css", value = ".RoadDistanceBtmSheet__nudgeWrapper > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(2) > span:nth-child(3) > span:nth-child(1)")$clickElement()
      remDr$executeScript("window.scrollTo(0,700);") # Scroll to the specific section
      html_page <- remDr$getPageSource()[[1]]
      La2 <- read_html(html_page) |> 
        html_nodes('div[class="RoadDistanceBtmSheet__itemName"]') %>% 
        html_text() %>% list()
    }else {
      La2 <- NA
    }
    
    if (element_exists("css", ".icon_goToTop")){
      remDr$findElement(using = "css", value = ".icon_goToTop")$clickElement()
      remDr$findElement(using = "css", value = "div.cc__CarouselBox:nth-child(2) > div:nth-child(1) > div:nth-child(3) > span:nth-child(3) > span:nth-child(1)")$clickElement()
      remDr$executeScript("window.scrollTo(0,700);") # Scroll to the specific section
      html_page <- remDr$getPageSource()[[1]]
      La3 <- read_html(html_page) |> 
        html_nodes('div[class="RoadDistanceBtmSheet__itemName"]') %>% 
        html_text() %>% list()
    } else {
      La3 <- NA
    }
    
    if (element_exists("css", "div.cc__whiteBg:nth-child(3) > i:nth-child(1)")){  
      remDr$findElement(using = "css", value = "div.cc__whiteBg:nth-child(3) > i:nth-child(1)")$clickElement()
      remDr$findElement(using = "css", value = "div.cc__CarouselBox:nth-child(2) > div:nth-child(1) > div:nth-child(4) > span:nth-child(3) > span:nth-child(1)")$clickElement()
      remDr$executeScript("window.scrollTo(0,700);") # Scroll to the specific section
      html_page <- remDr$getPageSource()[[1]]
      La4 <- read_html(html_page) |> 
        html_nodes('div[class="RoadDistanceBtmSheet__itemName"]') %>% 
        html_text() %>% list()
    } else {
      La4 <- NA
    }
    
      
    if (element_exists("css", "div.cc__whiteBg:nth-child(3) > i:nth-child(1)")){  
      remDr$findElement(using = "css", "div.cc__whiteBg:nth-child(3) > i:nth-child(1)")$clickElement()
      remDr$findElement(using = "css", value = "div.cc__CarouselBox:nth-child(2) > div:nth-child(1) > div:nth-child(5) > span:nth-child(3) > span:nth-child(1)")$clickElement()
      remDr$executeScript("window.scrollTo(0,700);") # Scroll to the specific section
      html_page <- remDr$getPageSource()[[1]]
      La5 <- read_html(html_page) |> 
        html_nodes('div[class="RoadDistanceBtmSheet__itemName"]') %>% 
        html_text() %>% list()
    } else {
      La5 <- NA
    }
     
    if (element_exists("css", "div.cc__whiteBg:nth-child(3) > i:nth-child(1)")){  
      remDr$findElement(using = "css", "div.cc__whiteBg:nth-child(3) > i:nth-child(1)")$clickElement()
      remDr$findElement(using = "css", value = "div.cc__CarouselBox:nth-child(2) > div:nth-child(1) > div:nth-child(6) > span:nth-child(3) > span:nth-child(1)")$clickElement()
      remDr$executeScript("window.scrollTo(0,700);") # Scroll to the specific section
      html_page <- remDr$getPageSource()[[1]]
      La6 <- read_html(html_page) |> 
        html_nodes('div[class="RoadDistanceBtmSheet__itemName"]') %>% 
        html_text() %>% list()
    } else {
      La6 <- NA
    }

    if (element_exists("css", "div.cc__whiteBg:nth-child(3) > i:nth-child(1)")){  
      remDr$findElement(using = "css", "div.cc__whiteBg:nth-child(3) > i:nth-child(1)")$clickElement()
      remDr$findElement(using = "css", value = "div.cc__CarouselBox:nth-child(2) > div:nth-child(1) > div:nth-child(7) > span:nth-child(3) > span:nth-child(1)")$clickElement()
      remDr$executeScript("window.scrollTo(0,700);") # Scroll to the specific section
      html_page <- remDr$getPageSource()[[1]]
      La7 <- read_html(html_page) |> 
        html_nodes('div[class="RoadDistanceBtmSheet__itemName"]') %>% 
        html_text() %>% list()
    } else {
      La7 <- NA
    }
    
    if (element_exists("css", "div.cc__whiteBg:nth-child(3) > i:nth-child(1)")){  
      remDr$findElement(using = "css", "div.cc__whiteBg:nth-child(3) > i:nth-child(1)")$clickElement()
    } else {
      La8 <- NA
    }
    
  Locational_advantages[i] <- mget(paste0('La', 1:8)) |> list()  
    
    
    
    
    if (!is.na(Locational_advantages[i])){  
      remDr$executeScript("window.scrollTo(0,700);") # Scroll to the specific section
      remDr$setTimeout(type = "implicit", milliseconds = 20000) # Wait to load the page
      if (element_exists("css", "#LANDMARK_VIEW_ALL")) {
        remDr$findElement(using = "css", value = "#LANDMARK_VIEW_ALL")$clickElement()
        remDr$executeScript("window.scrollTo(0,700);") # Scroll to the specific section
        html_page <- remDr$getPageSource()[[1]]
        La1 <- read_html(html_page) |> 
          html_nodes('div[class="RoadDistanceBtmSheet__distance"]') %>% 
          html_text() %>% list()
      } else {
        La1 <- NA
      }
      ### Next location
      
      if (element_exists("css", "i.pageComponent")) {
        remDr$findElement(using = "css", value = "i.pageComponent")$clickElement()
        remDr$findElement(using = "css", value = "#LANDMARK_VIEW_ALL")$clickElement()
        remDr$findElement(using = "css", value = ".RoadDistanceBtmSheet__nudgeWrapper > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(2) > span:nth-child(3) > span:nth-child(1)")$clickElement()
        remDr$executeScript("window.scrollTo(0,700);") # Scroll to the specific section
        html_page <- remDr$getPageSource()[[1]]
        La2 <- read_html(html_page) |> 
          html_nodes('div[class="RoadDistanceBtmSheet__distance"]') %>% 
          html_text() %>% list()
      }else {
        La2 <- NA
      }
      
      if (element_exists("css", ".icon_goToTop")){
        remDr$findElement(using = "css", value = ".icon_goToTop")$clickElement()
        remDr$findElement(using = "css", value = "div.cc__CarouselBox:nth-child(2) > div:nth-child(1) > div:nth-child(3) > span:nth-child(3) > span:nth-child(1)")$clickElement()
        remDr$executeScript("window.scrollTo(0,700);") # Scroll to the specific section
        html_page <- remDr$getPageSource()[[1]]
        La3 <- read_html(html_page) |> 
          html_nodes('div[class="RoadDistanceBtmSheet__distance"]') %>% 
          html_text() %>% list()
      } else {
        La3 <- NA
      }
      
      if (element_exists("css", "div.cc__whiteBg:nth-child(3) > i:nth-child(1)")){  
        remDr$findElement(using = "css", value = "div.cc__whiteBg:nth-child(3) > i:nth-child(1)")$clickElement()
        remDr$findElement(using = "css", value = "div.cc__CarouselBox:nth-child(2) > div:nth-child(1) > div:nth-child(4) > span:nth-child(3) > span:nth-child(1)")$clickElement()
        remDr$executeScript("window.scrollTo(0,700);") # Scroll to the specific section
        html_page <- remDr$getPageSource()[[1]]
        La4 <- read_html(html_page) |> 
          html_nodes('div[class="RoadDistanceBtmSheet__distance"]') %>% 
          html_text() %>% list()
      } else {
        La4 <- NA
      }
      
      
      if (element_exists("css", "div.cc__whiteBg:nth-child(3) > i:nth-child(1)")){  
        remDr$findElement(using = "css", "div.cc__whiteBg:nth-child(3) > i:nth-child(1)")$clickElement()
        remDr$findElement(using = "css", value = "div.cc__CarouselBox:nth-child(2) > div:nth-child(1) > div:nth-child(5) > span:nth-child(3) > span:nth-child(1)")$clickElement()
        remDr$executeScript("window.scrollTo(0,700);") # Scroll to the specific section
        html_page <- remDr$getPageSource()[[1]]
        La5 <- read_html(html_page) |> 
          html_nodes('div[class="RoadDistanceBtmSheet__distance"]') %>% 
          html_text() %>% list()
      } else {
        La5 <- NA
      }
      
      if (element_exists("css", "div.cc__whiteBg:nth-child(3) > i:nth-child(1)")){  
        remDr$findElement(using = "css", "div.cc__whiteBg:nth-child(3) > i:nth-child(1)")$clickElement()
        remDr$findElement(using = "css", value = "div.cc__CarouselBox:nth-child(2) > div:nth-child(1) > div:nth-child(6) > span:nth-child(3) > span:nth-child(1)")$clickElement()
        remDr$executeScript("window.scrollTo(0,700);") # Scroll to the specific section
        html_page <- remDr$getPageSource()[[1]]
        La6 <- read_html(html_page) |> 
          html_nodes('div[class="RoadDistanceBtmSheet__distance"]') %>% 
          html_text() %>% list()
      } else {
        La6 <- NA
      }
      
      if (element_exists("css", "div.cc__whiteBg:nth-child(3) > i:nth-child(1)")){  
        remDr$findElement(using = "css", "div.cc__whiteBg:nth-child(3) > i:nth-child(1)")$clickElement()
        remDr$findElement(using = "css", value = "div.cc__CarouselBox:nth-child(2) > div:nth-child(1) > div:nth-child(7) > span:nth-child(3) > span:nth-child(1)")$clickElement()
        remDr$executeScript("window.scrollTo(0,700);") # Scroll to the specific section
        html_page <- remDr$getPageSource()[[1]]
        La7 <- read_html(html_page) |> 
          html_nodes('div[class="RoadDistanceBtmSheet__distance"]') %>% 
          html_text() %>% list()
      } else {
        La7 <- NA
      }
      
      if (element_exists("css", "div.cc__whiteBg:nth-child(3) > i:nth-child(1)")){  
        remDr$findElement(using = "css", "div.cc__whiteBg:nth-child(3) > i:nth-child(1)")$clickElement()
      } else {
        La8 <- NA
      }
      
      Distance_to_locational_advantage[i] <- mget(paste0('La', 1:8)) |> list()  
      
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
  housing_data_page26 <- tibble(
    price = Price,
    bhk = Bhk,
    area_sqft = Area_sqft,
    latitude = Latitude ,
    longitude = Longitude ,
    top_facilities = Top_facilities,
    other_facilities = Other_facilities,
    locational_advantages = Locational_advantages,
    distance_to_locational_advantage = Distance_to_locational_advantage 
  )

toc()


