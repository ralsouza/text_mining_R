# Text Analytics em R

# Download do http://www.foolabs.com/xpdf/download.html

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

# Checar as fontes de dados, do pacote tm
getSources()

# Checar leitores, do pacote tm
getReaders()

#### 1. CONVERTER PDFs EM TXTs E MOVER TXTs PARA OUTRO DIRETÓRIO ####
# Organizar os documentos e diretórios para o pré-processamento

# Configurar o diretório com os documentos
dest <- '/home/ralsouza/Documents/r_projects/text_mining_R/corpus/pdf'

# Lista com os nomes completos dos arquivos do tipo PDF
myfiles <- list.files(path = dest, pattern = 'pdf', full.names = TRUE)
print(myfiles)

# Percorrer a lista do objeto myfiles e converter os pdfs para txt
# O lapply simula um loop for, percorrendo um conjunto de dados e aplica alguma coisa, neste caso executando o arquivo externo ao R
# o aplicativo para converter o pdf em txt
lapply(myfiles, function(i) system(paste('"/usr/bin/pdftotext"', paste0('"',i,'"')), wait = FALSE))

# Diretório Atual
current.folder <- '/home/ralsouza/Documents/r_projects/text_mining_R/corpus/pdf'
# Novo diretório
new.folder <- '/home/ralsouza/Documents/r_projects/text_mining_R/corpus/txt'

# Armazenar os caminhos e nomes dos arquivos txt em um objeto
list.of.files <- list.files(current.folder, '*txt$', full.names = TRUE)
list.of.files

# Copiar os arquivos txt para o novo diretório
file.copy( from = list.of.files
          ,to = new.folder)

#### 2. CRIAÇÃO DO CORPUS E PRÉ-PROCESSAMENTO ####
# Criação do Corpus e limpeza dos documentos a serem analisados

# Definir o diretório do Corpus
getwd()
# . é o diretório atual
# corpus o diretório dentro do diretório atual, '.'
# txt é o diretório dentro do diretório corpus
cname <- file.path('.', 'corpus', 'txt')

# Checar a quantidade de arquivos no diretório
length(dir(cname))

# Listar os arquivos
dir(cname)

# Definindo a fonte de dados e explorando o corpus
docs <- Corpus(DirSource(cname))
docs
class(docs)
class(docs[[1]])
summary(docs)
inspect(docs[16])

# Preparando o Corpus
?getTransformations
getTransformations()
# Criação da função para buscar um padrão e substituir por um espaço
toSpace <- content_transformer(function(x, pattern) gsub(pattern, ' ', x))
# Executar as seguintes limpezas
docs <- tm_map(docs, toSpace, '/')
docs <- tm_map(docs, toSpace, '@')
docs <- tm_map(docs, toSpace, '\\|')
docs <- tm_map(docs, toSpace, '/|@|\\|')
docs <- tm_map(docs, content_transformer(tolower))
docs <- tm_map(docs, removeNumbers)
docs <- tm_map(docs, removePunctuation)

# Remover Stopwords
# Palavras que aparecem em grande quantidade e que não são relevantes para a análise como: Artigos, conjunções, advérbios
?stopwords
# Quantas stopwords em inglês existem no pacote
length(stopwords('english'))
# Listar as stopwords
stopwords('english') # Stopwords em português basta alterar para 'pr-br'
# Remover as stopwords do Corpus
docs <- tm_map(docs, removeWords, stopwords('english'))
# Remover palavras específicas do Corpus
docs <- tm_map(docs, removeWords, c('departament', 'email'))
?stripWhitespace
# Retirar espaço em branco extra de um documento de texto
docs <- tm_map(docs, stripWhitespace)

# Converter texto para siglas, caso algum padrão já seja conhecido no arquivo
toString <- content_transformer(function(x, from, to) gsub(from, to , x))
docs <- tm_map(docs, toString, 'harbin institute technology', 'HIT')
docs <- tm_map(docs, toString, 'shenzhen institutes advanced technology', 'SIAT')
docs <- tm_map(docs, toString, 'chinese academy sciences', 'CAS')

# Stemming, para remover prefixos e sufixos, ou seja, tudo que aparecer antes ou depois da raíz da palavra será removido 
?stemDocument
docs <- tm_map(docs, stemDocument) # Verificar como fazer em português

#### 3. PROCESSAMENTO ESTATÍSTICO ####
# Converter o Corpus para permitir em um formato que permitirá realizar análise quantitativa
# Ao se tratar de textos é preciso realizar algum tipo de conversão de modo que o computador seja capaz de compreender 
# aquilo que temos no texto de forma matemática. Então precisamos converter o Corpus para uma matriz,
# utilizando Document-Term Matriz, " que descreve a 
# frequência de termos que ocorrem em uma coleção de documentos - https://en.wikipedia.org/wiki/Document-term_matrix ".
# Está é uma das primeiras etapas da fase de processamento, començando a compreender o que temos dentro dos arquivos extraindo insights

# Usa-se DocumentTermMatrix() para criar a matriz
# É simplesmente uma matriz com documentos como as linhas e termos com as colunas e uma contagem da frequência de palavras como células da matriz 
dtm <- DocumentTermMatrix(docs)

# A matriz de termo do documento é de fato bastante esparsa (isto é, na maior parte vazia) e assim é realmente 
# armazenada em uma representação muito mais compacta internamente
# É possível obter a contagem de linhas e colunas
# Verificar o tipo do objeto
class(dtm)
dtm
# Inspecionar as primeras 5 linhas e as colunas de 1000 à 1005
inspect(dtm[1:5, 1000:1005])
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
write.csv(m, file = 'dtm.csv')

#### RELACIONAMENTOS E ANÁLISE QUANTITATIVA ####
# Podemos iniciar a etapa de identificação de relacionamentos e uma análise quantitativa do conjunto de dados
# Perceba que nesta altura não temos mais um corpus, pois o corpus foi convertido para uma matriz do tipo termo-documento
# O processo do trabalho até aqui foi:
#   - Convertemos alguns arquivos de PDF para TXT;
#   - Juntamos estes arquivos TXT dentro de um Corpus;
#   - Fizemos alguns processamentos: Removemos pontuação, palavras stopwords, carácteres específicos;
#   - Convertemos para uma matriz;
#   - Calculamos algumas frequências;
#   - Agora atrávez de uma análise quantitativa, encontrar relacionamentos entre as palavras, palavras que aparecem com maior frequência, 
#     correlação entre as palavras, ou seja, identificar se duas palavras aparecem juntas no texto e com que frequencia elas aparecem juntas no texto.
#     Pois isso identificar um insight, nesta fase pode ser importante envolver alguém da área de negócio convidando a apresentar alguns gráficos, 
#     mostrar as palavras com maior ocorrência, mostrar as palavras que aparecem em conjunto, questionar o que pode ser modificado, que outras informações 
#     se esperava ver como resultado do Text Analytics. 

# Removendo termos esparsos
# Muitas vezes não estamos intressados em termo infrequentes em nossos documentos
# Tais termos "esparsos" podem ser removidos da matriz do termo do documento muito facilmente usando removeSparseTerms()
dim(dtm)
dtms <- removeSparseTerms(dtm, 0.1)

# Restaram as palavras que aparecem o tempo inteiro em todos os documentos, ou seja, as palavras mais relevantes
dim(dtms)
inspect(dtms)

# Podemos ver o efeito observando os temos que deixamos somando as frequencias
freq <- colSums(as.matrix(dtms))
# Listar os termos que aparecem com maior frequência
freq




























