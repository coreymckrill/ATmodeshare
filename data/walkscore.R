library(readr)

if (is.null(apikey)) {
    warning("The apikey variable is missing")
}

data_modeshare <- read_csv("data/modeshare.csv")

df <-
    data_modeshare |>
    select(site_id, latitude, longitude) |>
    mutate(
        walkscore = NA,
        bikescore = NA
    )

for (row in rownames(df)) {
    message(sprintf(
        "Processing row %s",
        row
    ))
    
    url <- sprintf(
        "https://api.walkscore.com/score?format=json&lat=%s&lon=%s&bike=1&wsapikey=%s",
        df[row, "latitude"],
        df[row, "longitude"],
        apikey
    )
    
    response <- jsonlite::fromJSON(url)
    
    df[row, "walkscore"] <- response$walkscore
    df[row, "bikescore"] <- response$bike$score
}

write.csv(
    df,
    "data/walkscore.csv",
    row.names = FALSE
)
