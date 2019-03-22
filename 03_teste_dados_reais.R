# Diretório de trabalho
setwd('/home/ralsouza/Documents/r_projects/text_mining_R')
getwd()

# Instalar os Pacotes
install.packages("tm")                           # Framework de text mining
install.packages("qdap")                         # Análise quantitativa do discurso de trasncripts
install.packages("qdapDictionaries")             # Dicionários
install.packages("dplyr")                        # Manipulação de Dados
install.packages("RColorBrewer")                 # Paleta de cores
install.packages("ggplot2")                      # Gráficos
install.packages("scales")                       # Permite incluir vírgulas em números, criando milhares
install.packages("SnowballC")                    # Implementa o algoritmo de stemming de Porter para reduzir palavras a uma raiz comum
install.packages("xlsx")
install.packages("ptstem")                       # https://github.com/dfalbel/ptstem Ver alternativa ao fim do post: https://pt.stackoverflow.com/questions/364543/stem-para-twitter 
install.packages("quanteda")
install.packages('gdata')                        # Permite trabalhar com arquivos xls
                  
# http://bioconductor.org/
source("http://bioconductor.org/biocLite.R")     # Biocondutor
biocLite("Rgraphviz")                            # Plots de correlação entre palavras

# Carregados os pacotes
library(tm) 
library(qdap) 
library(qdapDictionaries)
library(dplyr) 
library(RColorBrewer) 
library(ggplot2) 
library(scales) 
library(Rgraphviz)
library(SnowballC)
library(xlsx)
library(quanteda)
library(gdata)

# Checar as fontes de dados, do pacote tm
getSources()

# Checar leitores, do pacote tm
getReaders()

#### 1. CONVERTER XLSX EM TXT E MOVER TXT PARA OUTRO DIRETÓRIO ####
# Organizar os documentos e diretórios para o pré-processamento

# Configurar o diretório com os documentos
dest <- '/home/ralsouza/Documents/r_projects/text_mining_R/corpus_psatisfacao/xls'

# Lista com os nomes completos dos arquivos do tipo PDF
myfiles <- list.files(path = dest, pattern = 'xls', full.names = TRUE)
print(myfiles)

# Percorrer a lista do objeto myfiles e converter os xlsx para txt
# lapply(myfiles, function(i) system(paste('"/usr/bin/pdftotext"', paste0('"',i,'"')), wait = FALSE))
df.xls <- read.xlsx2(myfiles, sheetIndex = 1)
write.table(dfxlsx, '/home/ralsouza/Documents/r_projects/text_mining_R/corpus_psatisfacao/txt/jan_2018_PesquisaDeSatisfacao.txt')

#### 2. CRIAÇÃO DO CORPUS E PRÉ-PROCESSAMENTO ####
getwd()
cname <- file.path('.', 'corpus_psatisfacao', 'txt')

# Definindo a fonte de dados e explorando o corpus
docs <- Corpus(DirSource(cname))
docs
class(docs)
class(docs[[1]])
summary(docs)
inspect(docs[1])

# Preparando o Corpus
?getTransformations
# Criação da função para buscar um padrão e substituir por um espaço
toSpace <- content_transformer(function(x, pattern) gsub(pattern, ' ', x))
# Executar as seguintes limpezas
docs <- tm_map(docs, toSpace, '/')
docs <- tm_map(docs, toSpace, '@')
docs <- tm_map(docs, toSpace, '\\|')
docs <- tm_map(docs, toSpace, '/|@|\\|')
docs <- tm_map(docs, toSpace, '\n')
docs <- tm_map(docs, content_transformer(tolower))
docs <- tm_map(docs, removeNumbers)
docs <- tm_map(docs, removePunctuation)
# Retirar espaço em branco extra de um documento de texto
docs <- tm_map(docs, stripWhitespace)
# Remover palavras específicas do Corpus
docs <- tm_map(docs, removeWords, c('departament', 'email'))

# Remover Stopwords
stopwords('portuguese')
# Remover as stopwords do Corpus
docs <- tm_map(docs, removeWords, stopwords('portuguese'))

# Stemming, para remover prefixos e sufixos, ou seja, tudo que aparecer antes ou depois da raíz da palavra será removido 
?stemDocument
# corpus.temp <- tm_map(corpus, stemDocument, language = "english")
# docs2 <- dfm_wordstem(docs, language = "pt")
# docs2 <- tm_map(docs, dfm_wordstem, language = "pt")
docs <- tm_map(docs, stemDocument, language = "portuguese")






#### 3. PROCESSAMENTO ESTATÍSTICO ####
dtm <- DocumentTermMatrix(docs)
# Verificar o tipo do objeto
class(dtm)
dtm
# Inspecionar as primeras 5 linhas e as colunas de 1000 à 1005
inspect(dtm[1,1:2576])
# Checar a dimensão da matriz
dim(dtm)
# A transposição é criada usando TermDocumentMatrix()
tdm <- TermDocumentMatrix(docs)
tdm

# Obter as frequências dos termos como um vetor convertendo a matriz do termo do documento em uma
# matriz e somando as contagens das colunas
?colSums
freq <- colSums(as.matrix(dtm))
freq
length(freq)
ord <- order(freq)
freq[head(ord)]
freq[tail(ord)]

# Distribuição das frequências dos termos
head(table(freq), 15)
tail(table(freq), 15)

# Converter a matriz para csv e gravar para efetuar um backup
m <- as.matrix(dtm)
dim(m)
write.csv(m, file = 'jan_2018_psatisfacao_sicredi.csv')

#### 4. RELACIONAMENTOS E ANÁLISE QUANTITATIVA ####
dim(dtm)
dtms <- removeSparseTerms(dtm, 0.1)


# Restaram as palavras que aparecem o tempo inteiro em todos os documentos, ou seja, as palavras mais relevantes
dim(dtms)
inspect(dtms)

# Podemos ver o efeito observando os temos que deixamos somando as frequencias
freq <- colSums(as.matrix(dtms))
# Listar os termos que aparecem com maior frequência
freq

# Identificando termos frequentes e associações no arquivo original, antes da limpeza dos termos esparsos
# e visualizar as palavras que aparecem com altíssima frequência
findFreqTerms(dtm, lowfreq = 1000)
findFreqTerms(dtm, lowfreq = 100)

findAssocs(dtm, 'acess', corlimit = 0.6)

# Plot de correlação dos termos - Plot com as ligações entre os termos
dim(dtm)
plot(dtm, terms = findFreqTerms(dtm, lowfreq = 100)[1:50], corThreshold = 0.1)

# Plot da frequência das palavras
freq <- sort(colSums(as.matrix(dtm)), decreasing = TRUE)
head(freq, 14)

# Correlações
wf <- data.frame(word = names(freq), freq = freq)
head(wf)

# Plot com ggplot2
subset(wf, freq > 500) %>% 
  ggplot(aes(word, freq)) + 
  geom_bar(stat = 'identity') +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

#### 5. VISUALIZAÇÃO DE DADOS ####
install.packages('wordcloud')
library(wordcloud)

set.seed(142)
wordcloud(names(freq), freq, max.words = 100)

set.seed(142)
wordcloud(names(freq), freq, min.freq = 100, colors = brewer.pal(6, 'Dark2'))

set.seed(142)
wordcloud(names(freq), freq, min.freq = 100, scale = c(5, .1), colors = brewer.pal(6, 'Dark2'))

# Resultado final com resultado mais aprimorado
set.seed(142)
dark2 <- brewer.pal(6, 'Dark2')
wordcloud(names(freq), freq, min.freq = 100, rot.per = 0.2, colors = dark2)

# Ajustando os dados e calculando estatísticas
words <- dtm %>% 
  as.matrix %>% 
  colnames %>% 
  (function(x) x[nchar(x) < 20])

# Comprimento do conjunto de dados
length(words)
# Palavras que ocorrem com mais frequência
head(words, 15)
# Resumo dos dados
summary(nchar(words))
# Tabela de contagem
table(nchar(words))
# Distribuição de frequência
dist_tab(nchar(words))



data.frame(nletters = nchar(words)) %>% 
  ggplot(aes(x = nletters)) +
  geom_histogram(binwidth = 1) +
  geom_vline(xintercept = mean(nchar(words)),
             colour = 'green', size = 1, alpha = .5) +
  labs(x = 'Número de Letras', y = 'Número de Palavras')
# Análise: A medida que temos mais letras, temos menos palavras com mais letras
#          Temos menos palavras com grande comprimento, a maior parte das palavras são curtas
#          A linha verde é a média.



install.packages("stringr")
library(stringr)

# Letras que aparecem com maior frequência
words %>%
  str_split("") %>%
  sapply(function(x) x[-1]) %>%
  unlist %>%
  dist_tab %>%
  mutate(Letter=factor(toupper(interval),
                       levels=toupper(interval[order(freq)]))) %>%
  ggplot(aes(Letter, weight=percent)) +
  geom_bar() +
  coord_flip() +
  labs(y="Proporção") +
  scale_y_continuous(breaks=seq(0, 12, 2),
                     label=function(x) paste0(x, "%"),expand=c(0,0), limits=c(0,12))


# Heatmap: Mostra a posição da letra e a proporção, então a medida que as letras vão aparecendo dentro das palavras
#          a posição da letra lá dentro vai mostrando o nível de intensidade
words %>%
  lapply(function(x) sapply(letters, gregexpr, x, fixed=TRUE)) %>%
  unlist %>%
  (function(x) x[x!=-1]) %>%
  (function(x) setNames(x, gsub("\\d", "", names(x)))) %>%
  (function(x) apply(table(data.frame(letter=toupper(names(x)),
                                      position=unname(x))),
                     1, function(y) y/length(x))) %>%
  qheat(high="green", low="yellow", by.column=NULL,
        values=TRUE, digits=3, plot=FALSE) +
  labs(y="Letra", x="Posição") +
  theme(axis.text.x=element_text(angle=0)) +
  guides(fill=guide_legend(title="Proporção"))












