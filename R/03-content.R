# Content for Welcome modal
get_content_welcome <- function() {
    tagList(
        p(
            strong(
                "Welcome!"
            )
        ),
        p(
            "\"Active transportation\" is people making trips through some mode of physical activity, like walking or biking. \"Mode share\" is the percentage of trips made in a specific mode. This tool allows you to explore the active transportation mode share at different places around Corvallis, Oregon, comparing it to the motor vehicle mode share."
        ),
        p(
            HTML(
                paste(
                    icon("map-location-dot", style = "margin-right: 0.3rem;"),
                    "Map"
                )
            ),
        ),
        p(
            "Click on any circle marker on the map to see the active transportation mode share and number of trips per hour recorded for that location. Click anywhere off of a circle marker to return to the entire dataset. You can also use the filter options in the left sidebar to select different subsets of the data." 
        ),
        p(
            HTML(
                paste(
                    icon("chart-line", style = "margin-right: 0.3rem;"),
                    "Chart"
                )
            ),
        ),
        p(
            "Explore the data in a chart format, choosing which variables to compare."
        ),
        p(
            HTML(
                paste(
                    icon("circle-info", style = "margin-right: 0.3rem;"),
                    "FAQ"
                )
            ),
        ),
        p(
            "More info about active transportation, mode share, and the data."
        )
    )
}

# Content for FAQ tab
get_content_faq <- function() {
    items <- list(
        box(
            title = "Where did this data come from?",
            markdown("
The City of Corvallis did annual bicycle trip counts at a limited set of locations from 2012 to 2015. In 2025, the Transportation Action Team of the [Corvallis Sustainability Coalition](https://sustainablecorvallis.org/) decided to revive the trip counts, but include additional active transportation modes, and survey more locations. During a four-day span in October 2025, 42 volunteers spent 201 hours counting trips by mode at 91 different locations around the city.
            "),
            collapsible = TRUE,
            collapsed = TRUE,
            status = "info",
            width = NULL
        ),
        box(
            title = "What is active transportation?",
            markdown("
Active transportation, or active mobility, is the transport of people through non-motorized means based around human physical activity. The most common forms of active transportation in Corvallis are walking and bicycling, but other modes such as scooters and skateboards also count. In this case, devices with an electric assist, such as ebikes and escooters, are also included.
            "),
            collapsible = TRUE,
            collapsed = TRUE,
            status = "info",
            width = NULL
        ),
        box(
            title = "What is included in each of the active transportation categories in these data?",
            markdown("
* Bicycle: trips by bike and electric bike
* Pedestrian: walking trips
* Other: trips by scooter, electric scooter, skateboard, Onewheel, and, apparently, horse
            "),
            collapsible = TRUE,
            collapsed = TRUE,
            status = "info",
            width = NULL
        ),
        box(
            title = "What is mode share?",
            markdown("
Mode share, or modal share, is the percentage of trips taken using a given mode or type of transportation, such as car or bike. In this case we are comparing the mode share of active transportation to that of motor vehicles with observed data from specific locations.

Typically, mode share is measured as part of the American Community Survey (ACS) by the U.S. Census Bureau, where they ask people to self-report how they commute to work. For the year 2024, Corvallis's 5-year moving average bicycle mode share was 5.3% and the walking mode share was 9.9%<sup>1</sup>.
            "),
            footer = markdown("
1. U.S. Census Bureau. \"[Commuting Characteristics by Sex.](https://data.census.gov/table/ACSST5Y2024.S0801?q=commute+to+work&g=160XX00US4115800)\" American Community Survey, ACS 5-Year Estimates Subject Tables, Table S0801. Accessed on 28 May 2026.
            "),
            collapsible = TRUE,
            collapsed = TRUE,
            status = "info",
            width = NULL
        ),
        box(
            title = "Why does mode share matter?",
            markdown("
Studies have shown that communities that are less dependent on motor vehicles, where residents are able to go about their lives using alternative transportation modes such as walking and biking, are both physically and socially healthier<sup>1</sup>. There is also evidence that these types of communities enjoy increased prosperity because they have strong local businesses, attract more investment and tourism dollars, have increased property values, and have reduced road and infrastructure costs<sup>2</sup>. Motor vehicles, of course, are also significant contributors to the climate crisis<sup>3</sup>. So measuring mode share gives us valuable information that can be used to inform the public and set policy that can help make Corvallis a healthier, more prosperous place to live, while reducing its carbon footprint.
            "),
            footer = markdown("
1. Ione Avila-Palencia (2018). \"[The effects of transport mode use on self-perceived health, mental health, and social contact measures: A cross-sectional and longitudinal study](https://ui.adsabs.harvard.edu/abs/2018EnInt.120..199A/abstract)\". _Environment International_.
2. Colin Buchanan (2007). \"[Paved With Gold](https://webarchive.nationalarchives.gov.uk/ukgwa/20110118100601/http://www.cabe.org.uk/publications/paved-with-gold)\". _Commission for Architecture and the Built Environment_.
3. \"[Carbon Pollution from Transportation](https://web.archive.org/web/20260528005510/https://www.epa.gov/transportation-air-pollution-and-climate-change/carbon-pollution-transportation)\". _U.S. Environmental Protection Agency_. Accessed on 28 May 2026.
            "),
            collapsible = TRUE,
            collapsed = TRUE,
            status = "info",
            width = NULL
        ),
        box(
            title = "What are Walk Score and Bike Score?",
            markdown("
Walk Score is a measure of a location's walkability. It uses network analysis of walking routes around the location to determine which amenities are within a walkable distance (generally one mile) and assign points based on the number of those amenities and their proximity. Bike Score is the same concept, but assesses a greater bikable distance. Walk Score and Bike Score are products of Redfin, you can read more [on their site](https://www.walkscore.com/methodology.shtml).
            "),
            collapsible = TRUE,
            collapsed = TRUE,
            status = "info",
            width = NULL
        )
    )
}
