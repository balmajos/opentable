
'%ni%' <- Negate('%in%')

library(rvest)
library(xml2)
library(XML)
library(git2r)
library(RCurl)
library(httr)
library(RSelenium)
library(wdman)      # for web scraping
library(caTools)    # for web scraping

url <- "https://www.opentable.com/state-of-industry"


driver <- rsDriver(browser=c("chrome"), chromever="80.0.3987.106")
# remDr < - driver$client

# rD <- rsDriver(
#   port = 4567L,
#   browser = c("chrome"),
#   version = "80",
#   chromever = "latest",
#   geckover = "latest",
#   iedrver = NULL,
#   phantomver = "2.1.1",
#   verbose = TRUE,
#   check = TRUE
# )
remDr <- remoteDriver(remoteServerAddr = "localhost", port = 4567L, browserName = "chrome")
remDr$open()
remDr$navigate(url)


doc <- htmlParse(remDr$getPageSource()[[1]])
country <- readHTMLTable(doc)[[1]]

option <- remDr$findElement(using = 'xpath', '//*[@id="content"]/div/div/main/div[3]/select')
option$clickElement()
Sys.sleep(1)
option <- remDr$findElement(using = 'xpath', '//*[@id="content"]/div/div/main/div[3]/select/option[2]')
option$clickElement()
Sys.sleep(1)
doc <- htmlParse(remDr$getPageSource()[[1]])
state <- readHTMLTable(doc)[[1]]
option <- remDr$findElement(using = 'xpath', '//*[@id="content"]/div/div/main/div[3]/select/option[3]')
option$clickElement()
Sys.sleep(1)
doc <- htmlParse(remDr$getPageSource()[[1]])
city <- readHTMLTable(doc)[[1]]
remDr$close()


original_country <- read.csv('C:/users/redrabbit/desktop/opentable/opentable_country.csv')
original_country <- original_country[!duplicated(original_country),]
original_country$report_date <- as.Date(original_country$report_date)

colnames(country)[names(country)=='Name'] <- 'Country'
colnames(country)[2:ncol(country)] <- paste0(colnames(country)[2:ncol(country)],"/2020")
country <- reshape2::melt(data=country,id.vars=colnames(country)[1],measure.vars=colnames(country)[2:ncol(country)])
country$variable <- as.Date(country$variable,format="%m/%d/%y")
country$value <- gsub("%","",country$value)
country$value <- as.numeric(as.character(country$value))
country$value <- country$value/100
colnames(country)[names(country)=='variable'] <- 'report_date'
colnames(country)[names(country)=='value'] <- 'yoy_pct_change'


original_state <- read.csv('C:/users/redrabbit/desktop/opentable/opentable_state.csv')
original_state <- original_state[!duplicated(original_state),]
original_state$report_date <- as.Date(original_state$report_date)

colnames(state)[names(state)=='Name'] <- 'State'
colnames(state)[2:ncol(state)] <- paste0(colnames(state)[2:ncol(state)],"/2020")
state <- reshape2::melt(data=state,id.vars=colnames(state)[1],measure.vars=colnames(state)[2:ncol(state)])
state$variable <- as.Date(state$variable,format="%m/%d/%y")
state$value <- gsub("%","",state$value)
state$value <- as.numeric(as.character(state$value))
state$value <- state$value/100
colnames(state)[names(state)=='variable'] <- 'report_date'
colnames(state)[names(state)=='value'] <- 'yoy_pct_change'

noreport <- subset(original_state,original_state$State %ni% state$State)
locations <- original_state[,c(1,4)]
locations <- locations[!duplicated(locations),]
state <- dplyr::full_join(state,locations)
state <- state[complete.cases(state),]
state <- rbind(state,noreport)

original_city <- read.csv('C:/users/redrabbit/desktop/opentable/opentable_city.csv')
original_city <- original_city[!duplicated(original_city),]
original_city$report_date <- as.Date(original_city$report_date)
colnames(city)[names(city)=='Name'] <- 'City'
colnames(city)[2:ncol(city)] <- paste0(colnames(city)[2:ncol(city)],"/2020")
city <- reshape2::melt(data=city,id.vars=colnames(city)[1],measure.vars=colnames(city)[2:ncol(city)])
city$variable <- as.Date(city$variable,format="%m/%d/%y")
city$value <- gsub("%","",city$value)
city$value <- as.numeric(as.character(city$value))
city$value <- city$value/100
colnames(city)[names(city)=='variable'] <- 'report_date'
colnames(city)[names(city)=='value'] <- 'yoy_pct_change'
noreport <- subset(original_city,original_city$City %ni% original_city$City)
locations <- original_city[,c(1,4,5)]
locations <- locations[!duplicated(locations),]
city <- dplyr::full_join(city,locations)
city <- city[complete.cases(city),]
city <- rbind(city,noreport)


write.csv(country,'C:/users/redrabbit/desktop/opentable/opentable_country.csv',row.names = FALSE)
write.csv(state,'C:/users/redrabbit/desktop/opentable/opentable_state.csv',row.names = FALSE)
write.csv(city,'C:/users/redrabbit/desktop/opentable/opentable_city.csv',row.names = FALSE)

dir <- "C:/users/redrabbit/desktop/opentable/"
setwd(dir)
git2r::config(user.name = "balmajos",user.email = "balmajoseph@gmail.com")
cred_user_pass = git2r::cred_user_pass(username = "balmajos", password = "the37greenelephants")
git2r::add(path="C:/users/redrabbit/desktop/opentable/")
git2r::pull(credentials=cred_user_pass)
git2r::commit(message=paste0("Update Data ",Sys.time()))
git2r::push(credentials=cred_user_pass)

