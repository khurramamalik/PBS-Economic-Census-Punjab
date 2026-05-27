setwd('C:/Users/Khuram Afzal/Desktop/EC CENSUS')
suppressWarnings(suppressMessages(library(readxl)))

# Read all 4 files fully to understand pattern
for (f in c(
  'districts-punjabemployment-category.xlsx',
  'PUNJAB-DISTRICTS-PSIC-wise-1.xlsx',
  'Punjab-district-unit-type.xlsx',
  'punjab-unit-typeemployment-category.xlsx'
)) {
  cat('\n=====', f, '=====\n')
  df <- suppressWarnings(read_excel(f, sheet=1, col_names=FALSE))
  cat('Total rows:', nrow(df), '\n')
  print(head(df, 30))
}
