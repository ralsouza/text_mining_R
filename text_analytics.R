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

# Checar as fontes de dados, do pacote tm
getSources()

# Checar leitores, do pacote tm
getReaders()

#### 1. CONVERTER PDFs EM TXTs E MOVER TXTs PARA OUTRO DIRETÓRIO ####
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
toSpace <- content_transformer(function(x, pattern) gsub(pattern = ' ', x))

# Continuar em 04:57



































