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

#人工標記後，畫分類圖============================================

content <- read_csv("content.csv")

##1. 分類標記圖
labels <- c("想生", "不想生", "猶豫", "隨便", "不要生", "要生")
content1 <- content %>%
  select(marks) %>%
  filter(marks != 0) %>% #去除無關的
  group_by(marks) %>%
  summarise(numbers = n()) %>%
  mutate(name = factor(labels, levels = labels)) %>%
  arrange(desc(numbers)) %>%
  mutate(name = fct_reorder(name, numbers))

f1 <- ggplot(data = content1, mapping = aes(x=name, y= numbers)) +
  geom_bar(stat="identity", fill="#7272fc", alpha=.6, width=.4)+
  coord_flip() +
  xlab("") +
  theme_bw() +
  theme_grey(base_family = "STKaiti")
  geom_text(aes(label = numbers), hjust = 0)



#all content_que ngram斷詞======================================================
get_ngrams <- function(content) {
  txt <- gsub(" ", "", content)
  txt <- paste(txt, collapse = "")
  ch_vec <- strsplit(txt, "")
  onegram <- function (ch_vec) {
    tab_ch <- table(ch_vec)
    a <- sort(tab_ch, decreasing=T)
    return(a)
  }
  onegrams <- sapply(ch_vec, onegram, USE.NAMES = F)
  
  bigram <- function (ch_vec) {
    M <- length(ch_vec)
    bigrams <- paste(ch_vec[1:(M-1)], ch_vec[2:M], sep="")
    bigram <- table(bigrams)
    a <- sort(bigram, decreasing=T)
    return(a)
  }
  bigrams <- sapply(ch_vec, bigram, USE.NAMES = F)
  
  trigram <- function (ch_vec) {
    M <- length(ch_vec)
    trigrams <- paste(ch_vec[1:(M-2)], ch_vec[2:(M-1)], ch_vec[3:M], sep="")
    trigram <- table(trigrams)
    a <- sort(trigram, decreasing=T)
    return(a)
  }
  trigrams <- sapply(ch_vec, trigram, USE.NAMES = F)
  
  quagram <- function (ch_vec) {
    M <- length(ch_vec)
    quagrams <- paste(ch_vec[1:(M-3)], ch_vec[2:(M-2)], ch_vec[3:(M-1)], ch_vec[4:M], sep="")
    quagram <- table(quagrams)
    a <- sort(quagram, decreasing=T)
    return(a)
  }
  quagrams <- sapply(ch_vec, quagram, USE.NAMES = F)
  
  pentagram <- function (ch_vec) {
    M <- length(ch_vec)
    pentagrams <- paste(ch_vec[1:(M-4)], ch_vec[2:(M-3)], ch_vec[3:(M-2)], ch_vec[4:(M-1)], ch_vec[5:M], sep="")
    pentagram <- table(pentagrams)
    a <- sort(pentagram, decreasing=T)
    return(a)
  }
  pentagrams <- sapply(ch_vec, pentagram, USE.NAMES = F)
  
  sixgram <- function (ch_vec) {
    M <- length(ch_vec)
    sixgrams <- paste(ch_vec[1:(M-5)], ch_vec[2:(M-4)], ch_vec[3:(M-3)], ch_vec[4:(M-2)], ch_vec[5:(M-1)], ch_vec[6:M], sep="")
    sixgram <- table(sixgrams)
    a <- sort(sixgram, decreasing=T)
    return(a)
  }
  sixgrams <- sapply(ch_vec, sixgram, USE.NAMES = F)
  
  sevengram <- function (ch_vec) {
    M <- length(ch_vec)
    sevengrams <- paste(ch_vec[1:(M-6)], ch_vec[2:(M-5)], ch_vec[3:(M-4)], ch_vec[4:(M-3)], ch_vec[5:(M-2)], ch_vec[6:(M-1)], ch_vec[7:M], sep="")
    sevengram <- table(sevengrams)
    a <- sort(sevengram, decreasing=T)
    return(a)
  }
  sevengrams <- sapply(ch_vec, sevengram, USE.NAMES = F)

  get_rearranged <- function(x) {
    words <- rownames(x)
    df <- cbind(words, data.frame(x, row.names=NULL))
    df <- rename(df, freq = x)
    return(df)
  }

  a <- get_rearranged(bigrams)
  b <- get_rearranged(trigrams)
  c <- get_rearranged(quagrams)
  d <- get_rearranged(pentagrams)
  e <- get_rearranged(sixgrams)
  f <- get_rearranged(sevengrams)

  all_ngrams <- bind_rows(a,b,c,d,e,f)
  return(all_ngrams)
}

#全部的ngram
all_ngrams <- get_ngrams(content$content_ques)

#篩選有"不"的關鍵詞=============================================
negative_words <- str_match(all_ngrams$words, "^不.+")
negative_words <- negative_words[!is.na(negative_words)]
nwords <- all_ngrams %>%
  filter(words %in% negative_words)

write(nwords, "nwords.csv")
##利用詞頻大小人工篩選和"想不想生"相關的詞彙

##因為用ngram會有正向關鍵字重複計算的情況
##所以在人工篩選完反向關鍵字(包含"不"的關鍵詞後)
keywords <- read.csv("keywords.csv")

positive_words <- keywords$word %>%
  gsub(pattern = "不",., replacement = "")

pwords <- all_ngrams %>%
  filter(words %in% positive_words)
##用正向關鍵詞的詞頻減去反向的(人工做相減)

birth_keywords <- read_csv("birth_keywords.csv",locale = locale(encoding = "BIG5"))

##生不生關鍵詞比較圖===============================================

###2. 不想生相關詞頻排序
birth_keywords_N <- birth_keywords %>%
  select(N, freq) %>%
  mutate(N = factor(N, levels = N)) %>%
  arrange(desc(freq)) %>%
  top_n(10) %>%
  mutate(N = fct_reorder(N, freq))

f2 <- ggplot(data = birth_keywords_N, mapping = aes(x = N, y = freq)) +
  geom_bar(stat="identity", fill="#73d3ff", alpha=.6, width=.4)+
  coord_flip() +
  xlab("") +
  theme_bw() +
  geom_text(aes(label = freq), hjust = 0)

###3. 想生相關詞頻排序
birth_keywords_P <- birth_keywords %>%
  select(P, freq_1) %>%
  mutate(P = factor(P, levels = P)) %>%
  arrange(desc(freq_1)) %>%
  top_n(10) %>%
  mutate(P = fct_reorder(P, freq_1))

f3 <- ggplot(data = birth_keywords_P, mapping = aes(x = P, y = freq_1)) +
  geom_bar(stat="identity", fill="#f68060", alpha=.6, width=.4)+
  coord_flip() +
  xlab("") +
  theme_bw() +
  labs(y = "freq") +
  geom_text(aes(label = freq_1), hjust = 0)


#依照人工標記分類斷詞並用自行設置的user.dict篩選=====================

user.dict <- read_csv("user_dict.txt", col_names = FALSE) #自己設置的user.dict
users <- user.dict$X1
prewords <- c(birth_keywords$N, birth_keywords$P) #用於filter非原因的關鍵詞

###4. 想生和要生ngrams的關鍵字詞頻排序

content1_6 <- content %>%
  filter(marks %in% c(1,6))
data1_6 <- get_ngrams(content1_6$content_ques)

data1_6 <- data1_6 %>%
  filter(words %in% users) %>%
  filter(!(words %in% prewords)) %>%
  mutate(words = factor(words, levels = words)) %>%
  arrange(desc(freq)) %>%
  top_n(10) %>%
  mutate(words = fct_reorder(words, freq))

f4 <- ggplot(data = data1_6, mapping = aes(x = words, y = freq)) +
  geom_bar(stat="identity", fill="#f68060", alpha=.6, width=.4)+
  coord_flip() +
  xlab("") +
  theme_bw() +
  labs(y = "freq") +
  geom_text(aes(label = freq), hjust = 0)

###5. 不想生和不要生ngrams的關鍵字詞頻排序

content2_5 <- content %>%
  filter(marks %in% c(2,5))
data2_5 <- get_ngrams(content2_5$content_ques)

data2_5 <- data2_5 %>%
  filter(words %in% users) %>%
  filter(!(words %in% prewords)) %>%
  mutate(words = factor(words, levels = words)) %>%
  arrange(desc(freq)) %>%
  top_n(10) %>%
  mutate(words = fct_reorder(words, freq))

f5 <- ggplot(data = data2_5, mapping = aes(x = words, y = freq)) +
  geom_bar(stat="identity", fill="#73d3ff", alpha=.6, width=.4)+
  coord_flip() +
  xlab("") +
  theme_bw() +
  geom_text(aes(label = freq), hjust = 0)


###6. 猶豫ngrams的關鍵字詞頻排序
content3 <- content %>%
  filter(marks == 3)
data3 <- get_ngrams(content3$content_ques)

data3 <- data3 %>%
  filter(words %in% users) %>%
  filter(!(words %in% prewords)) %>%
  mutate(words = factor(words, levels = words)) %>%
  arrange(desc(freq)) %>%
  top_n(10) %>%
  mutate(words = fct_reorder(words, freq))

f6 <- ggplot(data = data3, mapping = aes(x = words, y = freq)) +
  geom_bar(stat="identity", fill="#ffe100", alpha=.6, width=.4)+
  coord_flip() +
  xlab("") +
  theme_bw() +
  geom_text(aes(label = freq), hjust = 0)