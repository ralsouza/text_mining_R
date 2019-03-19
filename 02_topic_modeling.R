# Topic Modeling em R

# Obs: Caso tenha problemas com a acentuação, consulte este link:
# https://support.rstudio.com/hc/en-us/articles/200532197-Character-Encoding

# Configurando o diretório de trabalho
# Coloque entre aspas o diretório de trabalho que você está usando no seu computador
# Não use diretórios com espaço no nome
setwd("Z:/Dropbox/DSA/Business-Analytics/R/Cap07")
getwd()

# Pacote
library(tm)

# Carregando os arquivos
dest <- "/Users/dmpm/Dropbox/DSA/Business-Analytics/R/Cap07/arquivos"
filenames <- list.files(dest, pattern = "*.txt",  full.names = TRUE)

# Lendo os nomes dos arquivos em um vetor
files <- lapply(filenames,readLines)

# Criando o Corpus
docs <- Corpus(VectorSource(files))

# Inspecionando um documento específico no Corpus
writeLines(as.character(docs[[30]]))

# Pré-rpocessamento
docs <- tm_map(docs,content_transformer(tolower))
toSpace <- content_transformer(function(x, pattern) { return (gsub(pattern, " ", x))})
docs <- tm_map(docs, toSpace, "-")
docs <- tm_map(docs, toSpace, "'")
docs <- tm_map(docs, toSpace, "'")
docs <- tm_map(docs, toSpace, "•")
docs <- tm_map(docs, removePunctuation)
docs <- tm_map(docs, removeNumbers)
docs <- tm_map(docs, removeWords, stopwords("english"))
docs <- tm_map(docs, stripWhitespace)
docs <- tm_map(docs,stemDocument)

# Criando a matriz termo-documento
dtm <- DocumentTermMatrix(docs)

# Convertendo o nome das linhas para o nome dos arquivos
rownames(dtm) <- filenames

# Somando as colunas
freq <- colSums(as.matrix(dtm))

# Número total de termos
length(freq)

# Ordenando
ord <- order(freq,decreasing=TRUE)

# listando os termos e gravando no arquivo
freq[ord]
write.csv(freq[ord], "word_freq.csv")


# Carregando o pacote topic models
install.packages("topicmodels")
library(topicmodels)

# Definindo parâmetros para a amostragem de Gibbs 
burnin <- 4000
iter <- 2000
thin <- 500
seed <- list(2003,5,63,100001,765)
nstart <- 5
best <- TRUE

# Número de tópicos
k <- 5

# Excutando o LDA na amostragem de Gibbs
?LDA
ldaOut <- LDA(dtm,k, 
              method = "Gibbs", 
              control = list(nstart = nstart, 
                             seed = seed, 
                             best = best, 
                             burnin = burnin, 
                             iter = iter, 
                             thin = thin))

# Gravando os resultados
ldaOut.topics <- as.matrix(topics(ldaOut))
write.csv(ldaOut.topics, file = paste("LDAGibbs", k, "DocsToTopics.csv"))

# Coletando os Termos Top 6 em cada tópico 
ldaOut.terms <- as.matrix(terms(ldaOut,6))
write.csv(ldaOut.terms, file = paste("LDAGibbs", k,  "TopicsToTerms.csv"))

# Probabilidades associadas com cada tópico
topicProbabilities <- as.data.frame(ldaOut@gamma)
write.csv(topicProbabilities, file = paste("LDAGibbs", k, "TopicProbabilities.csv"))                                   

# Encontrando a importância relativa para tópicos Top 2
topic1ToTopic2 <- lapply(1:nrow(dtm),function(x)
  sort(topicProbabilities[x,])[k]/sort(topicProbabilities[x,])[k-1])

# Encontrando importância relativa para segundo e terceiro tópicos mais importantes
topic2ToTopic3 <- lapply(1:nrow(dtm),function(x)
  sort(topicProbabilities[x,])[k-1]/sort(topicProbabilities[x,])[k-2])

# Gravando o resultado
write.csv(topic1ToTopic2, file = paste("LDAGibbs", k, "Topic1ToTopic2.csv"))
write.csv(topic2ToTopic3, file = paste("LDAGibbs", k, "Topic2ToTopic3.csv"))

