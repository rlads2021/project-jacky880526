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