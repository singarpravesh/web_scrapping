# install.packages("RSelenium")
# install.packages("dplyr")

library(RSelenium)
library(dplyr)

# Method 1
# Install chromedriver 
# Documentation at https://cran.r-project.org/web/packages/RSelenium/RSelenium.pdf page 16

rD <- rsDriver(browser="firefox",chromever = NULL, port=9511L, verbose=F)
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
coordinates <- list()

for (i in 1:2){
  rD <- rsDriver(browser="firefox",chromever = NULL, port=netstat::free_port(), verbose=F)
  remDr <- rD[["client"]]
  remDr$navigate(urls[i])
  
  
  price[i] <- remDr$findElements(using = "xpath", "//*[@class='list_header_semiBold configurationCards__configurationCardsHeading']") |> 
    sapply(function(x){x$getElementText()[[1]]})
  
  bhk[i] <- remDr$findElements(using = "xpath", "//*[@class='ellipsis list_header_semiBold configurationCards__configurationCardsSubHeading']") |> 
    sapply(function(x){x$getElementText()[[1]]})
  
  coordinates[i] <- remDr$findElements(using = "css selector", value="script[type='application/ld+json']" ) |> 
    sapply(function(x){x$getElementText()[[1]]})

  remDr$closeWindow()
  }


remDr$closeall()
rD <- rsDriver(browser="firefox",chromever = NULL, port = netstat::free_port() , verbose=F)
remDr <- rD[["client"]]
remDr$navigate(titles[1])
remDr$getCurrentUrl()



#################
rD <- rsDriver(browser="firefox",chromever = NULL, port=netstat::free_port(), verbose=F)
remDr <- rD[["client"]]
remDr$navigate(urls[1])
c <- remDr$findElements(using = "css selector", value="script[type='application/ld+json']" ) |> 
  sapply(function(x){x$executeScript("data-react-helmet")})

# Load the necessary libraries
library(jsonlite)
library(jsonld)

# URL of the website

script_tag <- remDr$findElement(using = "css selector", value = "script[type='application/ld+json']")
script_tag$executeScript()
# Send a GET request to the URL
response <- GET(urls[1])

# Parse the HTML content
html <- content(response, "text")

# Find the JSON-LD script tag
script_tag <- html %>% 
  html_nodes("script[type='application/ld+json']") %>% 
  html_text()

# Parse the JSON-LD content
data <- jsonlite::fromJSON(script_tag)

# Extract the latitude and longitude
latitude <- data$geo$latitude
longitude <- data$geo$longitude

print(paste("Latitude:", latitude, ", Longitude:", longitude))





#################



pricesElements <- remDr$findElements(using = "xpath", "//*[@class='price_color']")
prices <-  sapply(pricesElements, function(x){x$getElementText()[[1]]})
stockElements <- remDr$findElements(using = "xpath", "//*[@class='instock availability']")
stocks <-  sapply(stockElements, function(x){x$getElementText()[[1]]})

df <- data.frame(titles, prices, stocks)
remDr$close()


write.csv(df, "./books_selenium.csv")