library(tidyverse)

data <- read_csv("data/modeshare_streetpath_raw.csv")

data <-
    data |>
    select(site_id, BIKE_FAC, MULTIUSE_PATH) |>
    unique() |>
    mutate(
        across(
            where(is.character),
            ~ na_if(., "")
        )
    ) |>
    mutate(
        BIKE_FAC = ifelse(is.na(BIKE_FAC), "None", BIKE_FAC),
        MULTIUSE_PATH = ifelse(is.na(MULTIUSE_PATH), NA, TRUE),
        trueval = TRUE,
    ) |>
    pivot_wider(
        names_from = BIKE_FAC,
        values_from = trueval,
        values_fill = NA
    ) |>
    rename(
        "Multi-Use Path" = MULTIUSE_PATH
    ) |>
    pivot_longer(
        cols = ! c(site_id),
        names_to = "bike_infra",
        values_to = "trueval",
        values_drop_na = TRUE
    ) |>
    select(site_id, bike_infra)


# Save to a new file
write.csv(
    data,
    "data/bike_infra.csv",
    row.names = FALSE
)
