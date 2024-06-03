# 1. Packages

libs <- c(
    "terra",
    "sf",
    "tidyverse",
    "ggplot2",
    "rnaturalearth",
    "rnaturalearthdata"
)

installed_libraries <- libs %in% rownames(
    installed.packages()
)

if(any(installed_libraries == F)){
    install.packages(
        libs[!installed_libraries]
    )
}

invisible(
    lapply(
        libs, library, character.only = T
    )
)

# 2. Country Borders

country_sf <- ne_countries(scale = "medium", returnclass = "sf") %>%
    filter(admin == "Turkey")

plot(sf::st_geometry(country_sf))

# 3. Fetch Rivers and Roads

rivers <- ne_download(scale = 10, type = "rivers_lake_centerlines", category = "physical", returnclass = "sf") %>%
    st_intersection(country_sf)

roads <- ne_download(scale = 10, type = "roads", category = "cultural", returnclass = "sf") %>%
    st_intersection(country_sf)

# 4. Plot The Data

library(ggplot2)

map_plot <- ggplot() +
    geom_sf(data = country_sf, fill = NA, color = "black") +
    geom_sf(data = rivers, color = "blue", size = 0.5) +
    geom_sf(data = roads, color = "grey", size = 0.5) +
    theme_minimal() +
    ggtitle("Rivers and Roads of Turkey")

# Display the plot
print(map_plot)

# 5. Save the plot

ggsave("tr_rivers_roads.png", plot = map_plot, width = 10, height = 10)
