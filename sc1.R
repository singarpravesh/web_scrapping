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

urls <- remDr$findElements(using = "xpath", "//*[@class='ellipsis']")
urls_list <- sapply(titleElements, function(x){x$getElementAttribute("href")}[[1]])

rD <- rsDriver(browser="firefox",chromever = NULL, port = netstat::free_port() , verbose=F)
remDr <- rD[["client"]]
remDr$navigate(titles[1])
remDr$getCurrentUrl()

price <- remDr$findElements(using = "xpath", "//*[@class='list_header_semiBold configurationCards__configurationCardsHeading']")
prices <- sapply(price, function(x){x$getElementText()[[1]]})






pricesElements <- remDr$findElements(using = "xpath", "//*[@class='price_color']")
prices <-  sapply(pricesElements, function(x){x$getElementText()[[1]]})
stockElements <- remDr$findElements(using = "xpath", "//*[@class='instock availability']")
stocks <-  sapply(stockElements, function(x){x$getElementText()[[1]]})

df <- data.frame(titles, prices, stocks)
remDr$close()


write.csv(df, "./books_selenium.csv")