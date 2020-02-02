# [1] load data
setwd('C:\\Users\\samsung\\Desktop\\강의 등\\웹데이터분석')

# joe hisaishi
## The Name of Life
joe1 = readLines('comment_crawling_joe hisaishi_34,634,160.txt', encoding = 'UTF-8')
## Howl's Moving Castle
joe2 = readLines('comment_crawling_joe hisaishi_28,570,500.txt', encoding = 'UTF-8')
## Summer
joe3 = readLines('comment_crawling_joe hisaishi_9,569,659.txt', encoding = 'UTF-8')

# ryuichi sakamoto
## Merry Christmas Mr Lawrence
ryu1 = readLines('comment_crawling_ryuichi sakamoto_9,490,277.txt', encoding = 'UTF-8')
## Energy Flow
ryu2 = readLines('comment_crawling_ryuichi sakamoto_7,184,948.txt', encoding = 'UTF-8')
## Rain
ryu3 = readLines('comment_crawling_ryuichi sakamoto_6,031,819.txt', encoding = 'UTF-8')


# delete empty line 
joe1 = joe1[joe1 != '']
joe2 = joe2[joe2 != '']
joe3 = joe3[joe3 != '']
ryu1 = ryu1[ryu1 != '']
ryu2 = ryu2[ryu2 != '']
ryu3 = ryu3[ryu3 != '']

length(joe1)  # 178770
length(joe2)  # 144290
length(joe3)  # 119059
length(ryu1)  # 118044
length(ryu2)  # 170522
length(ryu3)  # 271059


# [2] word cloud
library(dplyr); library(stringr)
library(tidytext); library(tm)
library(ggplot2); library(wordcloud)

# remove non-english text
joe1_en = iconv(joe1, "latin1", "ASCII", sub="")
joe2_en = iconv(joe2, "latin1", "ASCII", sub="")
joe3_en = iconv(joe3, "latin1", "ASCII", sub="")
ryu1_en = iconv(ryu1, "latin1", "ASCII", sub="")
ryu2_en = iconv(ryu2, "latin1", "ASCII", sub="")
ryu3_en = iconv(ryu3, "latin1", "ASCII", sub="")

# remove numbers
joe1_en = removeNumbers(joe1_en)
joe2_en = removeNumbers(joe2_en)
joe3_en = removeNumbers(joe3_en)
ryu1_en = removeNumbers(ryu1_en)
ryu2_en = removeNumbers(ryu2_en)
ryu3_en = removeNumbers(ryu3_en)

joe1.df = data_frame(line=1:length(joe1_en), text=joe1_en)
joe2.df = data_frame(line=1:length(joe2_en), text=joe2_en)
joe3.df = data_frame(line=1:length(joe3_en), text=joe3_en)
ryu1.df = data_frame(line=1:length(ryu1_en), text=ryu1_en)
ryu2.df = data_frame(line=1:length(ryu2_en), text=ryu2_en)
ryu3.df = data_frame(line=1:length(ryu3_en), text=ryu3_en)

joe1.wd = joe1.df %>% unnest_tokens(word, text) %>% anti_join(stop_words) %>% count(word, sort=T) 
joe2.wd = joe2.df %>% unnest_tokens(word, text) %>% anti_join(stop_words) %>% count(word, sort=T) 
joe3.wd = joe3.df %>% unnest_tokens(word, text) %>% anti_join(stop_words) %>% count(word, sort=T) 
ryu1.wd = ryu1.df %>% unnest_tokens(word, text) %>% anti_join(stop_words) %>% count(word, sort=T) 
ryu2.wd = ryu2.df %>% unnest_tokens(word, text) %>% anti_join(stop_words) %>% count(word, sort=T) 
ryu3.wd = ryu3.df %>% unnest_tokens(word, text) %>% anti_join(stop_words) %>% count(word, sort=T) 

joe1.wd$title = 'The Name of Life'
joe2.wd$title = "Howl's Moving Castle"
joe3.wd$title = 'Summer'
ryu1.wd$title = 'Merry Christmas Mr Lawrence'
ryu2.wd$title = 'Energy Flow'
ryu3.wd$title = 'Rain'

all.wd = cbind(joe1.wd[1:20, c(1,3)], joe2.wd[1:20, c(1,3)], joe3.wd[1:20, c(1,3)], 
               ryu1.wd[1:20, c(1,3)], ryu2.wd[1:20, c(1,3)], ryu3.wd[1:20, c(1,3)])
all.wd

joe1.wd[1:20,]
joe2.wd[1:20,]
joe3.wd[1:20,]
ryu1.wd[1:20,]
ryu2.wd[1:20,]
ryu3.wd[1:20,]

# wordcloud
pal = brewer.pal(8, 'Dark2')
joe1.wd %>% with(wordcloud(word, n, color=pal, max.words=100))
joe2.wd %>% with(wordcloud(word, n, color=pal, max.words=100))
joe3.wd %>% with(wordcloud(word, n, color=pal, max.words=100))

pal = brewer.pal(8, 'Set2')
ryu1.wd %>% with(wordcloud(word, n, color=pal, max.words=100))
ryu2.wd %>% with(wordcloud(word, n, color=pal, max.words=100))
ryu3.wd %>% with(wordcloud(word, n, color=pal, max.words=100))


# [3] sentiment analysis

# a function to calculate positive/ negative scores
FUN = function(sentence, pos.words, neg.words)
{ # remove punctuation
  sentence = gsub("[[:punct:]]", "", sentence)
  # remove control characters
  sentence = gsub("[[:cntrl:]]", "", sentence)
  # remove digits?
  sentence = gsub('\\d+', '', sentence)
  
  # define error handling function when trying tolower
  tryTolower = function(x)
  { # create missing value
    y = NA
    # tryCatch error
    try_error = tryCatch(tolower(x), error=function(e) e)
    # if not an error
    if (!inherits(try_error, "error"))
      y = tolower(x)
    # result
    return(y)
  }
  
  # use tryTolower with sapply
  sentence = sapply(sentence, tryTolower)
  
  # split sentence into words with str_split (stringr package)
  word.list = str_split(sentence, "\\s+")
  words = unlist(word.list)
  
  # compare words to the dictionaries of positive & negative terms
  pos.matches = match(words, pos.words)
  neg.matches = match(words, neg.words)
  
  # get the position of the matched term or NA
  # we just want a TRUE/FALSE
  pos.matches = !is.na(pos.matches)
  neg.matches = !is.na(neg.matches)
  
  # final score
  score = sum(pos.matches) - sum(neg.matches)
  return(score)
}

# score calculation
score.sentiment = function(sentences, pos.words, neg.words)
{
  # Parameters
  # sentences: vector of text to score
  # pos.words: vector of words of postive sentiment
  # neg.words: vector of words of negative sentiment
  # create simple array of scores with laply
  scores = sapply(sentences, FUN, pos.words, neg.words)
  # data frame with scores for each sentence
  scores.df = data.frame(text=sentences, score=scores)
  return(scores.df)
}

# read lexicons
pos.words = scan('positive-words.txt', what='character', comment.char=';')
neg.words = scan('negative-words.txt', what='character', comment.char=';')

joe1.scores = score.sentiment(joe1, pos.words, neg.words)
joe2.scores = score.sentiment(joe2, pos.words, neg.words)
joe3.scores = score.sentiment(joe3, pos.words, neg.words)
ryu1.scores = score.sentiment(ryu1, pos.words, neg.words)
ryu2.scores = score.sentiment(ryu2, pos.words, neg.words)
ryu3.scores = score.sentiment(ryu3, pos.words, neg.words)

joe1.scores$title = 'The Name of Life'
joe2.scores$title = "Howl's Moving Castle"
joe3.scores$title = 'Summer'
ryu1.scores$title = 'Merry Christmas Mr Lawrence'
ryu2.scores$title = 'Energy Flow'
ryu3.scores$title = 'Rain'

all.scores = rbind(joe1.scores, joe2.scores, joe3.scores,
                   ryu1.scores, ryu2.scores, ryu3.scores)

all.scores %>% group_by(title) %>% summarise(mean_score = mean(score)) %>% 
  arrange(desc(mean_score))

ggplot(data=all.scores, aes(x=score, group=title)) +
  geom_histogram(aes(fill=title), binwidth=1) +
  facet_grid(title~.) +
  theme_bw() +
  labs(title="Barplot - Sentiment Scores")

ggplot(data=all.scores, aes(x=title, y=score, group=title)) +
  geom_boxplot(aes(fill=title)) +
  #geom_jitter() +
  labs(title="Boxplot - Sentiment Scores")

