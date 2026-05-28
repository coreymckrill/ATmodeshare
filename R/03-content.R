# Content for Welcome modal
get_content_welcome <- function() {
    markdown("
Welcome to the Corvallis Active Transportation Mode Share Explorer! Here you can peruse mode share data for Corvallis, Oregon, slice and dice it in different ways, and see a representative mode share for locations around the city.   
    ")
}

# Content for FAQ tab
get_content_about <- function() {
    markdown("
### What do I do with this?

Click on any circle marker on the map to see the active transportation mode share and number of trips per hour counted for that location. Click anywhere off of a circle marker to return to the entire dataset. You can also use the filter options in the left sidebar to select different subsets of the data.

### What is active transportation?

Active transportation, or active mobility, is the transport of people through non-motorized means based around human physical activity. The most common forms of active transportation in Corvallis are walking and bicycling, but other modes such as scooters and skateboards also count. In this case, devices with an electric assist, such as ebikes and escooters, are also included.

### What does mode share mean?

Mode share, or modal share, is the percentage of trips taken using a given mode or type of transportation, such as car or bike. In this case we are comparing the mode share of active transportation to that of motor vehicles.

### Why does mode share matter?

Studies have shown that communities that are less dependent on motor vehicles, where residents are able to go about their lives using alternative transportation modes such as walking and biking, are both physically and socially healthier. There is also evidence that these types of communities enjoy increased prosperity because they have strong local businesses, attract more investment and tourism dollars, have increased property values, and have reduced road and infrastructure costs. Motor vehicles, of course, are also significant contributors to the climate crisis. So measuring mode share gives us valuable information that can be used to inform the public and set policy that can help make Corvallis a healthier, more prosperous place to live, while reducing its carbon footprint.

### Where did this data come from?

The City of Corvallis did annual bicycle trip counts at a limited set of locations from 2012 to 2015, but then it stopped. In 2025, the Transportation Action Team of the [Corvallis Sustainability Coalition](https://sustainablecorvallis.org/) decided to revive the trip counts, but count all trip modes, and do it at more locations. During a four-day span in October 2025, 42 volunteers spent 201 hours counting trips and their modes at 91 different locations around the city.
    ")
}
