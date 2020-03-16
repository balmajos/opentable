library(rvest)
library(xml2)

url <- "https://docs.google.com/spreadsheets/d/e/2PACX-1vRbPuAyJy74UmbF6kLXFGXDk2eX3N6zvRLzxPamG8FAA3E-SVqMOMSIht-eYEF_4qrNGOJuPbDjTsPD/pubhtml#"
webpage <- read_html(url)

tbl <- html_table(webpage, header = NA, trim = TRUE, fill = FALSE, dec = ".")
country <- tbl[[2]]
state <- tbl[[3]]
city <- tbl[[4]]

country <- country[,-c(1:2,ncol(country))]
country <- country[-c(1:7,nrow(country)),]
country[1,1] <- 'locale'
colnames(country) <- country[1,]
country <- country[-1,]
colnames(country)[2:ncol(country)] <- paste0(colnames(country)[2:ncol(country)],"/2020")
country <- reshape2::melt(data=country,id.vars=colnames(country)[1],measure.vars=colnames(country)[2:ncol(country)])
country$variable <- as.Date(country$variable,format="%m/%d/%y")
country$value <- gsub("%","",country$value)
country$value <- as.numeric(as.character(country$value))
country$value <- country$value/100
colnames(country)[names(country)=='variable'] <- 'report_date'
colnames(country)[names(country)=='value'] <- 'yoy_pct_change'

state <- state[,-c(1:2,ncol(state))]
state <- state[-c(1:7,nrow(state)),]
colnames(state) <- state[1,]
state <- state[-1,]
colnames(state)[3:ncol(state)] <- paste0(colnames(state)[3:ncol(state)],"/2020")
state <- reshape2::melt(data=state,id.vars=colnames(state)[1:2],measure.vars=colnames(state)[3:ncol(state)])
state$variable <- as.Date(state$variable,format="%m/%d/%y")
state$value <- gsub("%","",state$value)
state$value <- as.numeric(as.character(state$value))
state$value <- state$value/100
colnames(state)[names(state)=='variable'] <- 'report_date'
colnames(state)[names(state)=='value'] <- 'yoy_pct_change'


city <- city[,-c(1:2,ncol(city))]
city <- city[-c(1:7,nrow(city)),]
colnames(city) <- city[1,]
city <- city[-1,]
colnames(city)[4:ncol(city)] <- paste0(colnames(city)[4:ncol(city)],"/2020")
city <- reshape2::melt(data=city,id.vars=colnames(city)[1:3],measure.vars=colnames(city)[4:ncol(city)])
city$variable <- as.Date(city$variable,format="%m/%d/%y")
city$value <- gsub("%","",city$value)
city$value <- as.numeric(as.character(city$value))
city$value <- city$value/100
colnames(city)[names(city)=='variable'] <- 'report_date'
colnames(city)[names(city)=='value'] <- 'yoy_pct_change'

write.csv(country,'C:/users/redrabbit/desktop/opentable/opentable_country.csv',row.names = FALSE)
write.csv(state,'C:/users/redrabbit/desktop/opentable/opentable_state.csv',row.names = FALSE)
write.csv(city,'C:/users/redrabbit/desktop/opentable/opentable_city.csv',row.names = FALSE)





# tbls <- html_nodes(webpage, "table")
# tbls_ls <- webpage %>%
#   html_nodes("table") %>%
#   .[4:4] %>%
#   html_table(fill = TRUE)
# 
# 
# # empty list to add table data to
# tbls2_ls <- list()
# # scrape Table 2. Nonfarm employment...
# tbls2_ls$Table1 <- webpage %>%
#   html_nodes("#Table2") %>% 
#   html_table(fill = TRUE) %>%
#   .[[1]]