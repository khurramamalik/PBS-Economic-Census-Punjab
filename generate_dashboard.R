setwd('C:/Users/Khuram Afzal/Desktop/EC CENSUS')
suppressWarnings(suppressMessages(library(readxl)))
suppressWarnings(suppressMessages(library(jsonlite)))

# Division -> District mapping
division_map <- list(
  "Bahawalpur" = c("BAHAWALNAGAR", "BAHAWALPUR", "RAHIM YAR KHAN"),
  "D.G. Khan"  = c("DERA GHAZI KHAN", "LAYYAH", "MUZAFFARGARH", "RAJANPUR"),
  "Faisalabad" = c("CHINIOT", "FAISALABAD", "JHUNG", "TOBA TEK SINGH"),
  "Gujranwala" = c("GUJRANWALA", "GUJRAT", "HAFIZABAD", "MANDI BAHAUDDIN", "NAROWAL", "SIALKOT"),
  "Lahore"     = c("KASUR", "LAHORE", "NANKANA SAHIB", "SHEIKHUPURA"),
  "Multan"     = c("KHANEWAL", "LODHRAN", "MULTAN", "VEHARI"),
  "Rawalpindi" = c("ATTOCK", "CHAKWAL", "JEHLUM", "RAWALPINDI"),
  "Sahiwal"    = c("OKARA", "PAKPATTAN", "SAHIWAL"),
  "Sargodha"   = c("BHAKKAR", "KHUSHAB", "MIANWALI", "SARGODHA")
)

# Tehsils per district
tehsil_map <- list(
  "ATTOCK"         = c("Attock", "Fateh Jang", "Hazro", "Jand", "Pindigheb", "Talagang"),
  "BAHAWALNAGAR"   = c("Bahawalnagar", "Chishtian", "Fort Abbas", "Haroonabad", "Minchinabad"),
  "BAHAWALPUR"     = c("Ahmadpur East", "Bahawalpur", "Hasilpur", "Kahror Pakka", "Khairpur Tamewali", "Yazman"),
  "BHAKKAR"        = c("Bhakkar", "Darya Khan", "Kalur Kot", "Mankera"),
  "CHAKWAL"        = c("Chakwal", "Choa Saidan Shah", "Kallar Kahar", "Talagang"),
  "CHINIOT"        = c("Bhawana", "Chiniot", "Lalian"),
  "DERA GHAZI KHAN"= c("D.G. Khan", "Kot Chutta", "Taunsa", "Vehova"),
  "FAISALABAD"     = c("Chak Jhumra", "Faisalabad City", "Faisalabad Saddar", "Jaranwala", "Samundri", "Tandlianwala"),
  "GUJRANWALA"     = c("Gujranwala", "Kamoke", "Khangah Dogran", "Noshera Virkan", "Wazirabad"),
  "GUJRAT"         = c("Gujrat", "Kharian", "Sarai Alamgir"),
  "HAFIZABAD"      = c("Hafizabad", "Pindi Bhattian", "Sukheke"),
  "JEHLUM"         = c("Jhelum", "Pind Dadan Khan", "Sohawa"),
  "JHUNG"          = c("Jhang", "Shorkot", "Ahmad Pur Sial"),
  "KASUR"          = c("Chunian", "Kasur", "Kot Radha Kishan", "Pattoki"),
  "KHANEWAL"       = c("Jehanian", "Kabirwala", "Khanewal", "Mian Channu"),
  "KHUSHAB"        = c("Joharabad", "Khushab", "Noorpur", "Quaidabad"),
  "LAHORE"         = c("Lahore City", "Lahore Cantt.", "Model Town", "Raiwind", "Shalimar"),
  "LAYYAH"         = c("Chaubara", "Karor Lal Esan", "Layyah"),
  "LODHRAN"        = c("Dunyapur", "Kehror Pakka", "Lodhran"),
  "MANDI BAHAUDDIN"= c("Malikwal", "Mandi Bahauddin", "Phalia"),
  "MIANWALI"       = c("Isa Khel", "Mianwali", "Piplan"),
  "MULTAN"         = c("Jalalpur Pirwala", "Multan City", "Multan Saddar", "Shujabad"),
  "MUZAFFARGARH"   = c("Ali Pur", "Jatoi", "Kot Addu", "Muzaffargarh"),
  "NANKANA SAHIB"  = c("Nankana Sahib", "Sangla Hill", "Shahkot"),
  "NAROWAL"        = c("Narowal", "Shakargarh", "Zafarwal"),
  "OKARA"          = c("Depalpur", "Okara", "Renala Khurd"),
  "PAKPATTAN"      = c("Arifwala", "Pakpattan"),
  "RAHIM YAR KHAN" = c("Khan Pur", "Liaquatpur", "Rahimyar Khan", "Sadiqabad"),
  "RAJANPUR"       = c("Jampur", "Kot Mithan", "Rajanpur", "Rojhan"),
  "RAWALPINDI"     = c("Gujar Khan", "Kahuta", "Kallar Syedan", "Murree", "Rawalpindi", "Taxila"),
  "SAHIWAL"        = c("Chichawatni", "Sahiwal"),
  "SARGODHA"       = c("Bhalwal", "Kot Momin", "Sahiwal", "Sargodha", "Shahpur", "Sillanwali"),
  "SHEIKHUPURA"    = c("Ferozewala", "Muridke", "Sheikhupura", "Safdarabad"),
  "SIALKOT"        = c("Daska", "Pasrur", "Sambrial", "Sialkot"),
  "TOBA TEK SINGH" = c("Kamalia", "Gojra", "Pir Mahal", "Toba Tek Singh"),
  "VEHARI"         = c("Burewala", "Mailsi", "Vehari")
)

# Parse PSIC data (Table 1)
parse_psic <- function() {
  df <- suppressWarnings(read_excel('PUNJAB-DISTRICTS-PSIC-wise-1.xlsx', sheet=1, col_names=FALSE))
  districts <- list()
  current <- NULL; rows <- list()
  for (i in 1:nrow(df)) {
    r1<-df[[i,1]]; r2<-df[[i,2]]; r3<-df[[i,3]]; r4<-df[[i,4]]; r5<-df[[i,5]]
    if (!is.na(r1) && is.na(r2) && is.na(r3) && is.na(r4) && is.na(r5) &&
        !grepl('^Table|^\\*|^Note', r1)) {
      if (!is.null(current)) districts[[current]] <- rows
      current <- trimws(r1); rows <- list(); next
    }
    if (!is.na(r1) && grepl('^[0-9]+$', trimws(r1)) && !is.na(r2) && !is.na(r4)) {
      rows[[length(rows)+1]] <- list(
        description=trimws(r2), psic=if(!is.na(r3)) trimws(r3) else '',
        establishments=suppressWarnings(as.numeric(r4)),
        workforce=suppressWarnings(as.numeric(r5))
      )
    }
    if (!is.na(r1) && is.na(r2) && !is.na(r4) && !is.na(r5) && !grepl('^[A-Z]', trimws(r1))) {
      rows[['total']] <- list(description='Total',
        establishments=suppressWarnings(as.numeric(r4)),
        workforce=suppressWarnings(as.numeric(r5)))
    }
  }
  if (!is.null(current)) districts[[current]] <- rows
  districts
}

# Parse Employment Category (Table 3)
parse_employment <- function() {
  df <- suppressWarnings(read_excel('districts-punjabemployment-category.xlsx', sheet=1, col_names=FALSE))
  districts <- list()
  current <- NULL; rows <- list()
  for (i in 1:nrow(df)) {
    r1<-df[[i,1]]; r2<-df[[i,2]]; r3<-df[[i,3]]; r4<-df[[i,4]]; r5<-df[[i,5]]
    if (!is.na(r1) && is.na(r2) && is.na(r3) && is.na(r4) && is.na(r5) &&
        !grepl('^TABLE|^Sr\\.|^\\*|^Note', r1)) {
      if (!is.null(current)) districts[[current]] <- rows
      current <- gsub(' DISTRICT$','',trimws(r1)); rows <- list(); next
    }
    if (!is.na(r1) && grepl('^[0-9]+$', trimws(r1)) && !is.na(r2) && !is.na(r4)) {
      rows[[length(rows)+1]] <- list(
        description=trimws(r2), psic=if(!is.na(r3)) trimws(r3) else '',
        less_than_10=suppressWarnings(as.numeric(r4)),
        ten_and_above=suppressWarnings(as.numeric(r5))
      )
    }
    if (!is.na(r1) && is.na(r2) && !is.na(r4) && !grepl('^[A-Z]', trimws(r1))) {
      rows[['total']] <- list(description='Total',
        less_than_10=suppressWarnings(as.numeric(r4)),
        ten_and_above=suppressWarnings(as.numeric(r5)))
    }
  }
  if (!is.null(current)) districts[[current]] <- rows
  districts
}

# Parse Unit Type (Table 2)
parse_unit_type <- function() {
  df <- suppressWarnings(read_excel('Punjab-district-unit-type.xlsx', sheet=1, col_names=FALSE))
  districts <- list()
  current <- NULL; rows <- list()
  for (i in 1:nrow(df)) {
    r1<-df[[i,1]]; r2<-df[[i,2]]; r3<-df[[i,3]]; r4<-df[[i,4]]
    if (!is.na(r1) && is.na(r2) && is.na(r3) && is.na(r4) &&
        !grepl('^TABLE|^\\*|^Note', r1)) {
      if (!is.null(current)) districts[[current]] <- rows
      current <- gsub(' DISTRICT$','',trimws(r1)); rows <- list(); next
    }
    if (!is.na(r1) && !grepl('^[0-9]|^TABLE|^Description|^Total', trimws(r1), ignore.case=TRUE) && !is.na(r2)) {
      ut <- suppressWarnings(as.integer(r2))
      e  <- suppressWarnings(as.numeric(r3))
      w  <- suppressWarnings(as.numeric(r4))
      if (!is.na(ut) && !is.na(e)) {
        rows[[length(rows)+1]] <- list(
          description=trimws(r1), unit_type=ut,
          establishments=e, workforce=if(!is.na(w)) w else 0
        )
      }
    }
  }
  if (!is.null(current)) districts[[current]] <- rows
  districts
}

# Parse Unit Type + Employment (Table 4)
parse_unit_employment <- function() {
  df <- suppressWarnings(read_excel('punjab-unit-typeemployment-category.xlsx', sheet=1, col_names=FALSE))
  districts <- list()
  current <- NULL; rows <- list()
  for (i in 1:nrow(df)) {
    r1<-df[[i,1]]; r2<-df[[i,2]]; r3<-df[[i,3]]; r4<-df[[i,4]]
    if (!is.na(r1) && is.na(r2) && is.na(r3) && is.na(r4) &&
        !grepl('^TABLE|^\\*|^Note', r1)) {
      if (!is.null(current)) districts[[current]] <- rows
      current <- gsub(' DISTRICT$','',trimws(r1)); rows <- list(); next
    }
    if (!is.na(r1) && !grepl('^[0-9]|^TABLE|^Description|^Total', trimws(r1), ignore.case=TRUE) && !is.na(r2)) {
      ut  <- suppressWarnings(as.integer(r2))
      lt  <- suppressWarnings(as.numeric(r3))
      gt  <- suppressWarnings(as.numeric(r4))
      if (!is.na(ut) && !is.na(lt)) {
        rows[[length(rows)+1]] <- list(
          description=trimws(r1), unit_type=ut,
          less_than_10=lt, ten_and_above=if(!is.na(gt)) gt else 0
        )
      }
    }
  }
  if (!is.null(current)) districts[[current]] <- rows
  districts
}

cat('Parsing data...\n')
psic_data       <- parse_psic()
employment_data <- parse_employment()
unit_type_data  <- parse_unit_type()
unit_emp_data   <- parse_unit_employment()

# Combine all district data
all_districts <- unique(c(names(psic_data), names(employment_data),
                           names(unit_type_data), names(unit_emp_data)))

dashboard_data <- list(
  divisions = division_map,
  tehsils   = tehsil_map,
  psic      = psic_data,
  employment = employment_data,
  unit_type  = unit_type_data,
  unit_employment = unit_emp_data
)

json_data <- toJSON(dashboard_data, auto_unbox=TRUE, null='null', na='null')

cat('Data parsed. Districts total:', length(all_districts), '\n')
cat('Writing JSON to file...\n')
writeLines(as.character(json_data), 'dashboard_data.json')
cat('Done.\n')
