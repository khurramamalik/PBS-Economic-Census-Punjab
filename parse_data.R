setwd('C:/Users/Khuram Afzal/Desktop/EC CENSUS')
suppressWarnings(suppressMessages(library(readxl)))
suppressWarnings(suppressMessages(library(jsonlite)))

# === Parse File 1: PSIC wise (No. of Establishments + Workforce) ===
parse_psic <- function() {
  df <- suppressWarnings(read_excel('PUNJAB-DISTRICTS-PSIC-wise-1.xlsx', sheet=1, col_names=FALSE))

  districts <- list()
  current_district <- NULL
  rows <- list()

  for (i in 1:nrow(df)) {
    r1 <- df[[i,1]]; r2 <- df[[i,2]]; r3 <- df[[i,3]]; r4 <- df[[i,4]]; r5 <- df[[i,5]]

    # District header: col1 has value, col2-5 NA
    if (!is.na(r1) && is.na(r2) && is.na(r3) && is.na(r4) && is.na(r5) &&
        !grepl('^Table', r1, ignore.case=TRUE)) {
      if (!is.null(current_district)) {
        districts[[current_district]] <- rows
      }
      current_district <- trimws(r1)
      rows <- list()
      next
    }

    # Data rows: col1 is numeric, or col1 is NA but col4 (total) has value
    if (!is.na(r1) && grepl('^[0-9]+$', trimws(r1)) && !is.na(r2) && !is.na(r4)) {
      rows[[length(rows)+1]] <- list(
        sr = as.integer(r1),
        description = trimws(r2),
        psic = if(!is.na(r3)) trimws(r3) else '',
        establishments = suppressWarnings(as.numeric(r4)),
        workforce = suppressWarnings(as.numeric(r5))
      )
    }
    # Total row
    if (!is.na(r1) && is.na(r2) && !is.na(r4) && !is.na(r5)) {
      rows[['total']] <- list(
        description = 'Total',
        establishments = suppressWarnings(as.numeric(r4)),
        workforce = suppressWarnings(as.numeric(r5))
      )
    }
  }
  if (!is.null(current_district)) districts[[current_district]] <- rows

  districts
}

# === Parse File 2: Employment Category ===
parse_employment <- function() {
  df <- suppressWarnings(read_excel('districts-punjabemployment-category.xlsx', sheet=1, col_names=FALSE))

  districts <- list()
  current_district <- NULL
  rows <- list()

  for (i in 1:nrow(df)) {
    r1 <- df[[i,1]]; r2 <- df[[i,2]]; r3 <- df[[i,3]]; r4 <- df[[i,4]]; r5 <- df[[i,5]]

    if (!is.na(r1) && is.na(r2) && is.na(r3) && is.na(r4) && is.na(r5) &&
        !grepl('^TABLE|^\\*|^Note', r1, ignore.case=FALSE)) {
      if (!is.null(current_district)) districts[[current_district]] <- rows
      current_district <- gsub(' DISTRICT$', '', trimws(r1))
      rows <- list()
      next
    }

    if (!is.na(r1) && grepl('^[0-9]+$', trimws(r1)) && !is.na(r2) && !is.na(r4)) {
      rows[[length(rows)+1]] <- list(
        sr = as.integer(r1),
        description = trimws(r2),
        psic = if(!is.na(r3)) trimws(r3) else '',
        less_than_10 = suppressWarnings(as.numeric(r4)),
        ten_and_above = suppressWarnings(as.numeric(r5))
      )
    }
    # Total
    if (!is.na(r1) && is.na(r2) && !is.na(r4)) {
      rows[['total']] <- list(
        description = 'Total',
        less_than_10 = suppressWarnings(as.numeric(r4)),
        ten_and_above = suppressWarnings(as.numeric(r5))
      )
    }
  }
  if (!is.null(current_district)) districts[[current_district]] <- rows
  districts
}

# === Parse File 3: Unit Type (Establishments + Workforce) ===
parse_unit_type <- function() {
  df <- suppressWarnings(read_excel('Punjab-district-unit-type.xlsx', sheet=1, col_names=FALSE))

  districts <- list()
  current_district <- NULL
  rows <- list()

  for (i in 1:nrow(df)) {
    r1 <- df[[i,1]]; r2 <- df[[i,2]]; r3 <- df[[i,3]]; r4 <- df[[i,4]]

    if (!is.na(r1) && is.na(r2) && is.na(r3) && is.na(r4) &&
        !grepl('^TABLE|^\\*|^Note', r1, ignore.case=FALSE)) {
      if (!is.null(current_district)) districts[[current_district]] <- rows
      current_district <- gsub(' DISTRICT$', '', trimws(r1))
      rows <- list()
      next
    }

    if (!is.na(r1) && !grepl('^[0-9]', trimws(r1)) && !is.na(r2) && !is.na(r3)) {
      desc <- trimws(r1)
      unit_type <- suppressWarnings(as.integer(r2))
      estab <- suppressWarnings(as.numeric(r3))
      wf <- suppressWarnings(as.numeric(r4))
      if (!is.na(unit_type) && !is.na(estab)) {
        rows[[length(rows)+1]] <- list(
          description = desc,
          unit_type = unit_type,
          establishments = estab,
          workforce = if(!is.na(wf)) wf else 0
        )
      }
    }
    # Total
    if (!is.na(r1) && grepl('Total', r1, ignore.case=TRUE) && !is.na(r3)) {
      rows[['total']] <- list(
        description = 'Total',
        establishments = suppressWarnings(as.numeric(r3)),
        workforce = suppressWarnings(as.numeric(r4))
      )
    }
  }
  if (!is.null(current_district)) districts[[current_district]] <- rows
  districts
}

# === Parse File 4: Unit Type + Employment Category ===
parse_unit_employment <- function() {
  df <- suppressWarnings(read_excel('punjab-unit-typeemployment-category.xlsx', sheet=1, col_names=FALSE))

  districts <- list()
  current_district <- NULL
  rows <- list()

  for (i in 1:nrow(df)) {
    r1 <- df[[i,1]]; r2 <- df[[i,2]]; r3 <- df[[i,3]]; r4 <- df[[i,4]]

    if (!is.na(r1) && is.na(r2) && is.na(r3) && is.na(r4) &&
        !grepl('^TABLE|^\\*|^Note', r1, ignore.case=FALSE)) {
      if (!is.null(current_district)) districts[[current_district]] <- rows
      current_district <- gsub(' DISTRICT$', '', trimws(r1))
      rows <- list()
      next
    }

    if (!is.na(r1) && !grepl('^[0-9]', trimws(r1)) && !is.na(r2) && !is.na(r3)) {
      desc <- trimws(r1)
      unit_type <- suppressWarnings(as.integer(r2))
      lt10 <- suppressWarnings(as.numeric(r3))
      gt10 <- suppressWarnings(as.numeric(r4))
      if (!is.na(unit_type) && !is.na(lt10)) {
        rows[[length(rows)+1]] <- list(
          description = desc,
          unit_type = unit_type,
          less_than_10 = lt10,
          ten_and_above = if(!is.na(gt10)) gt10 else 0
        )
      }
    }
    if (!is.na(r1) && grepl('Total', r1, ignore.case=TRUE) && !is.na(r3)) {
      rows[['total']] <- list(
        description = 'Total',
        less_than_10 = suppressWarnings(as.numeric(r3)),
        ten_and_above = suppressWarnings(as.numeric(r4))
      )
    }
  }
  if (!is.null(current_district)) districts[[current_district]] <- rows
  districts
}

cat('Parsing all files...\n')
psic_data <- parse_psic()
employment_data <- parse_employment()
unit_type_data <- parse_unit_type()
unit_employment_data <- parse_unit_employment()

cat('Districts in PSIC:', length(psic_data), '\n')
cat(paste(names(psic_data), collapse=', '), '\n')
cat('Districts in Employment:', length(employment_data), '\n')
cat('Districts in Unit Type:', length(unit_type_data), '\n')
cat('Districts in Unit Employment:', length(unit_employment_data), '\n')

# Show sample data for one district
cat('\nSample PSIC data for ATTOCK:\n')
print(psic_data[['ATTOCK']])
