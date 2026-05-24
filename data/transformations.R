library(readr)

data <- read_csv("data/modeshare.csv")

# Fix incorrect wards
data[data$site_id == "602.1", "ward"] <- 6
data[data$site_id == "702", "ward"] <- NA



test <- data

