



for(i in 1:length(myfiles)){
  filenames <- sub('*.xls', '',list.files(path = dest, pattern = 'xls', full.names = FALSE))
  df_teste <- filenames[i]
  df_teste <- read.xlsx2(myfiles[i], sheetIndex = 1)
}




assign('teste', filenames)
