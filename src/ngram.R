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