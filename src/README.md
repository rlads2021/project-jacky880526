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

- [data_process原始碼](./data_process.R)

### 函數
get_content_link: 取得文章超連結  
get_data: 獲得文章的內文  

### 彙整
 
將收集到的資料（共392篇文章），年份為2017～2021年，進行資料清理，去除日期、網頁、引述、全形標點符號、半形標點符號、空白及斷行符號。  

將整理好的資料儲存至"Womentalk_content.csv"  

- [Womentalk_content.csv](./Womentalk_content.csv)

## 將整理好的資料進行人工標記

將文章分為「無關」（0）、「想生」（1）、「不想生」（2）、「猶豫」（3）、「隨便」（4）、「不要生」（5）、「要生」（6）七大類，將文章存入"content.csv"

- [content.csv](./content.csv)

## 繪製分類標記圖

刪除「無關」類之後，將六類大類與生育有關的類別繪製成長條圖，輸出成"f1.png"

- [分類標記圖（f1.png）](./f1.png)

## ngram斷詞函數

將文章進行單字詞至七字詞組的斷詞。

-[ngram原始碼](./ngram.R)

## 分析及繪圖  
- [分析及繪圖原始碼](./analysis_and_plot)

### 生/不生小孩文章類型  
依據我們標記出的文章分類，進一步探討生育與否的文章類型

不生小孩文章類型  
-[不生小孩文章類型（f2.png）](./f2.png)

生小孩文章類型    
-[生小孩文章類型（f3.png）](./f3.png)

### 用我們在資料中找到的關鍵字（原因）進行「生小孩與否」原因分析和繪圖  

-[關鍵字（user_dict）](./user_dict.txt)

不生小孩關鍵詞    
-[不生小孩關鍵字（f5.png）](./f5.png)

生小孩關鍵詞  
-[生小孩關鍵字（f4.png）](./f4.png)

猶豫和隨便類型關鍵詞  
-[猶豫、隨便關鍵字（f6/png）](./f6.png)


