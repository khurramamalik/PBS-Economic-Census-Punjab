setwd('C:/Users/Khuram Afzal/Desktop/EC CENSUS')
suppressWarnings(suppressMessages(library(readxl)))

# Read file 1 - show all rows to find districts
f1 <- suppressWarnings(read_excel('PUNJAB-DISTRICTS-PSIC-wise-1.xlsx', sheet=1, col_names=FALSE))
cat('=== File 1 ALL rows ===\n')
for (i in 1:nrow(f1)) {
  row <- f1[i,]
  if (!is.na(row[[1]]) && (grepl('DISTRICT|District|DIVISION|Division|TEHSIL|Tehsil', row[[1]], ignore.case=TRUE) ||
      (is.na(row[[2]]) && !grepl('^[0-9]', row[[1]])))) {
    cat('Row', i, ':', row[[1]], '\n')
  }
}

cat('\n\n=== File 2 (Table 3) district headers ===\n')
f2 <- suppressWarnings(read_excel('districts-punjabemployment-category.xlsx', sheet=1, col_names=FALSE))
for (i in 1:nrow(f2)) {
  row <- f2[i,]
  if (!is.na(row[[1]]) && is.na(row[[2]]) && !grepl('^[0-9]', row[[1]]) && !grepl('TABLE|Sr\\.', row[[1]])) {
    cat('Row', i, ':', row[[1]], '\n')
  }
}
