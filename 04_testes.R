

# Criar vetor com os nomes dos arquivos
filenames <- sub('*.xls', '',list.files(path = dest, pattern = 'xls', full.names = FALSE))

# Novo diretório
new.folder <- '/home/ralsouza/Documents/r_projects/text_mining_R/corpus_psatisfacao/txt'

for(i in 1:length(myfiles)){
  # Atribui os dados
  df_xls <- read.xlsx2(myfiles[i], sheetIndex = 1, header = FALSE, startRow = 2)
  # Seleciona o nome do arquivo
  nome_novo <- filenames[i]
  write.table(df_xls, paste0('/home/ralsouza/Documents/r_projects/text_mining_R/corpus_psatisfacao/txt/',nome_novo, '.txt'))
}

