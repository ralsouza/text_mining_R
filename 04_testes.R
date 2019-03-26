



# Configurar o diretório com os documentos
src_folder <- '/home/ralsouza/Documents/r_projects/text_mining_R/corpus_psatisfacao/xls'

# Lista com os nomes completos dos arquivos do tipo PDF
full_path <- list.files(path = src_folder, pattern = 'xls', full.names = TRUE)

# Criar vetor com os nomes dos arquivos
filenames <- sub('*.xls', '',list.files(path = src_folder, pattern = 'xls', full.names = FALSE))

# Novo diretório
new_folder <- '/home/ralsouza/Documents/r_projects/text_mining_R/corpus_psatisfacao/txt'

for(i in 1:length(filenames)){
  # Atribui os dados
  df_xls <- read.xlsx2(full_path[i], sheetIndex = 1, header = FALSE, startRow = 2)
  # Seleciona o nome do arquivo
  nome_novo <- filenames[i]
  write.table(df_xls, paste0('/home/ralsouza/Documents/r_projects/text_mining_R/corpus_psatisfacao/txt/',nome_novo, '.txt'))
}

