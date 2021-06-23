# 原始碼說明文件

## 需要的套件

這份原始碼是在"R version 4.1.0"底下運行，並用到以下幾個套件：  
httr  
stringr  
rvest  
dplyr  
ggplot2  
readr  
tidyverse  
tm

## 資料取得、整理（PTT網頁爬蟲）  

- [data_process](./data_process.R)

### 函數
get_content_link: 取得文章超連結  
get_data: 獲得文章的內文  

### 彙整
 
將收集到的資料（共392篇文章），年份為2017～2021年，進行資料清理，去除日期、網頁、引述、全形標點符號、半形標點符號、空白及斷行符號。  

將整理好的資料儲存至"Womentalk_content.csv"  

- [Womentalk_content.csv](./Womentalk_content.csv)

## 將整理好的資料進行人工標記

將文章分為「無關」、「想生」、「不想生」、「要生」、「不要生」、「隨便」、「隨便」七大類，將文章存入"content.csv"

## 繪製分類標記圖

將六類大類與生育有關的類別繪製成長條圖，輸出成"f1.png"

- [分類標記圖](./f1.png)

## ngram斷詞函數

get_ngrams: 













