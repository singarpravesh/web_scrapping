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

for (i in 1:2){
  rD <- rsDriver(browser="firefox",chromever = NULL, port=netstat::free_port(), verbose=F)
  remDr <- rD[["client"]]
  remDr$navigate(urls[i])
  
  
  price[i] <- remDr$findElements(using = "xpath", "//*[@class='list_header_semiBold configurationCards__configurationCardsHeading']") |> 
    sapply(function(x){x$getElementText()[[1]]})
  
  bhk[i] <- remDr$findElements(using = "xpath", "//*[@class='ellipsis list_header_semiBold configurationCards__configurationCardsSubHeading']") |> 
    sapply(function(x){x$getElementText()[[1]]})
 
    # latitude
  html <- read_html_live(urls[i])
  json_ld_script <- html_elements(html, xpath = 'script[type="application/ld+json"]')
  json_ld_data <- lapply(json_ld_script, function(x) {
    json_str <- html_text(x)
    fromJSON(json_str)
  })
  latitude[i] <- json_ld_data[[3]]$geo$latitude
  remove(html)
  remove(json_ld_script)
  remove(json_ld_data)
  
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
# Find all script tags with type="application/ld+json"
script_tags <- remDr$findElements(using = 'css selector', 'script[type="application/ld+json"]')
remDr$
# Extract the text content of each script tag
json_data <- lapply(script_tags, function(tag) {
  tag$getElementText()
})

# Parse the JSON data
json_list <- lapply(json_data, function(x) {
  jsonlite::fromJSON(x[[1]], simplifyVector = FALSE)
})

# Fetch the webpage content
url <- "https://example.com"
html <- read_html_live(urls[1])

# Extract the JSON-LD script tag
json_ld_script <- html_nodes(html, "script[type='application/ld+json']")

# Parse the JSON-LD data
json_ld_data <- lapply(json_ld_script, function(x) {
  json_str <- html_text(x)
  fromJSON(json_str)
})

json_ld_data[[3]]$geo$latitude

# Access the parsed data
print(json_ld_data[[1]]$headline)
print(json_ld_data[[1]]$`@type`)
print(json_ld_data[[1]]$alternativeHeadline)

latitude <- read_html_live(urls[1]) |> 
  html_nodes("script[type='application/ld+json']") |> 
  lapply(.,function(x) {
    json_str <- html_text(x)
    fromJSON(json_str)
  }) 


#######################

html <- read_html_live(urls[2])
json_ld_script <- html_nodes(html, "script[type='application/ld+json']")
json_ld_data <- lapply(json_ld_script, function(x) {
  json_str <- html_text(x)
  fromJSON(json_str)
})
latitude <- json_ld_data[[3]]$geo$latitude
chrome$close()

##############################
library(rvest)
library(chromote)
latitude <- c()
# Create a new Chrome session
chrome <- chromote::Chrome$new()

# Use read_html_live() to fetch HTML content

for (i in 1:2) {
  html <- read_html(urls[1])
  
  # Interact with the fetched HTML content
  json_ld_script <- html_nodes(html, "script[type='application/ld+json']")
  json_ld_data <- lapply(json_ld_script, function(x) {
    json_str <- html_text(x)
    fromJSON(json_str)
  })
  latitude[i] <- json_ld_data[[3]]$geo$latitude
  remove(html)
  remove(json_ld_data)
  remove(json_ld_script)
}

# Close the Chrome session
chrome$close()



################################
remDr$findElement(using = "xpath", value = "//script[@type='application/ld+json']")$getElementText()
remDr$findElements(using = "css", value="script[type='application/ld+json']")|> 
  sapply(function(x){x$getElementText()[[1]]}) |> 
  jsonlite::fromJSON()

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