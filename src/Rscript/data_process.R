library(httr)
library(stringr)
library(rvest)
library(dplyr)
library(ggplot2)
library(readr)
library(tidyverse)

#ptt crawling=====================================================
get_content_link <- function(x) {
  resp <- GET(x)
  html <- content(resp)
  content_link <- html %>% html_nodes(".title > a") %>% html_attr("href")
  return(content_link)
}

get_data <- function(x){
  resp <- GET("https://www.ptt.cc", path = x)
  html <- content(resp)
  author <- html %>% html_nodes("div:nth-child(1) > span.article-meta-value") %>% html_text() %>% trimws()
  title <- html %>% html_nodes("div:nth-child(3) > span.article-meta-value") %>% html_text() %>% trimws()
  date <- html %>% html_nodes("div:nth-child(4) > span.article-meta-value") %>% html_text() %>% trimws()
  content <- html %>% html_nodes("#main-content") %>% html_text() %>% trimws()
  df <- tibble::tibble(author = author, 
                       title = title, 
                       date = date, 
                       content = content)
  return(df)
}


###keyword == 生小孩
resp1 <- vector("character", 16)
for (i in 1:16) {
  resp1[i] <- paste0("https://www.ptt.cc/bbs/WomenTalksearch?page=", i, "&q=%E7%94%9F%E5%B0%8F%E5%AD%A9")
}

###keyword == 養小孩
resp2 <- vector("character", 4)
for (j in 1:4) {
  resp2[j] <- paste0("https://www.ptt.cc/bbs/WomenTalk/search?page=", j, "&q=%E9%A4%8A%E5%B0%8F%E5%AD%A9")
}

###keyword == 生子 
resp3 <- vector("character", 5)
for (k in 1:5) {
  resp3[k] <- paste0("https://www.ptt.cc/bbs/WomenTalk/search?page=", k, "&q=%E7%94%9F%E5%AD%90")
}

###keyword == 生孩子
resp4 <- "https://www.ptt.cc/bbs/WomenTalk/search?page=1&q=%E7%94%9F%E5%AD%A9%E5%AD%90"

resp <- c(resp1, resp2, resp3, resp4)

content_links <- unlist(sapply(resp, get_content_link, USE.NAMES = FALSE))
all_data <- sapply(content_links, get_data, USE.NAMES = FALSE)

##transfer matrix to dataframe
all_data <- t(all_data)
df <- tibble::tibble(author = unlist(all_data[,1]),
                     title = unlist(all_data[,2]),
                     date = unlist(all_data[,3]),
                     content = unlist(all_data[,4]))

#內容清理=======================================================
library(tm)
content_ques <- df$content %>% gsub(pattern = "作者.+:[0-9]{2}\\s[0-9]{4}?",., replacement = "") %>% # 去頭 
  gsub(pattern = "(\n--\n※).+",., replacement = "")  # 去尾

content_ques <- content_ques %>%
  gsub(pattern = "(http|https)://[a-zA-Z0-9./?=_-]+",., replacement = "") %>% #去除網頁
  gsub(pattern = "引述《[a-zA-Z0-9./_()].+》之銘言",., replacement = "") %>% #去除引述
  gsub(pattern = "Sent from [a-zA-Z0-9 -./_()]+",., replacement = "") %>% #去除Sent from
  gsub(pattern = "<U[a-zA-Z0-9 +]+>",., replacement = "") %>% #去除光碟
  gsub(pattern = "[0-9]{4}/[0-9]{2}/[0-9]{2}",., replacement = "") %>% #去除日期格式:2020/01/16
  gsub(pattern = "[0-9]{4}-[0-9]{2}-[0-9]{2}",., replacement = "") %>% #去除日期格式:2020-01-16
  gsub(pattern = "[0-9]{4}年[0-9]{1,2}月[0-9]{1,2}日",., replacement = "") %>% #去除日期格式:2020年1月16日
  gsub(pattern = "[0-9]{1,2}/[0-9]{1,2}",., replacement = "") %>% #去除日期格式:01/22
  gsub(pattern = "[0-9]{1,2}-[0-9]{1,2}",., replacement = "") %>% #去除日期格式:01-22
  gsub(pattern = "[0-9]{1,2}月[0-9]{1,2}日",., replacement = "") %>% #去除日期格式:01月22日
  gsub(pattern = "[0-9]{2}:[0-9]{2}",., replacement = "") %>% #去除時間
  gsub(pattern = "新聞網址",., replacement = "") %>% 
  gsub(pattern = "\n",., replacement = "") %>% # 清理斷行符號
  gsub(pattern = "[/_.★↑｜▲△～─→──┐─╱┘●※]+?",.,replacement = "")

content_ques <- removePunctuation(content_ques,ucp=T) #去除全形標點符號
content_ques <- removePunctuation(content_ques) #去除半形標點符號
content_ques <- stripWhitespace(content_ques) #去除空白
df <- cbind(df, content_ques)

##export the data
write.csv(df, "Womentalk_content.csv")