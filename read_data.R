setwd('C:/Users/Khuram Afzal/Desktop/EC CENSUS')
suppressWarnings(library(readxl))

files <- c(
  'districts-punjabemployment-category.xlsx',
  'PUNJAB-DISTRICTS-PSIC-wise-1.xlsx',
  'Punjab-district-unit-type.xlsx',
  'punjab-unit-typeemployment-category.xlsx'
)

for (f in files) {
  cat('\n==========', f, '==========\n')
  sheets <- excel_sheets(f)
  cat('Sheets:', paste(sheets, collapse=', '), '\n')
  for (s in sheets) {
    cat('\n--- Sheet:', s, '---\n')
    df <- suppressWarnings(read_excel(f, sheet=s))
    cat('Dims:', nrow(df), 'rows x', ncol(df), 'cols\n')
    cat('Columns:', paste(names(df), collapse=' | '), '\n')
    print(head(df, 5))
  }
}
