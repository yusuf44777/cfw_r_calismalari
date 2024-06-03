# 1. PACKAGES

libs <- c(
    "terra",
    "sf",
    "tidyverse",
    "ggplot2",
    "rnaturalearth",
    "rnaturalearthdata",
    "svglite",
    "ggspatial"
)

installed_libraries <- libs %in% rownames(
    installed.packages()
)

if(any(installed_libraries == FALSE)){
    install.packages(
        libs[!installed_libraries]
    )
}

invisible(
    lapply(
        libs, library, character.only = TRUE
    )
)

# 2. COUNTRY BORDERS

world_sf <- ne_countries(scale = "medium", returnclass = "sf")

plot(sf::st_geometry(world_sf))

# 3. FETCH ROADS DATA

roads <- ne_download(scale = 10, type = "roads", category = "cultural", returnclass = "sf")

# 4. FILTER FOR HIGHWAYS
# Note: The filtering attribute may vary. Check the 'roads' data structure to identify the correct attribute.
# Assuming the attribute is 'featurecla' and highways are coded as 'Highway'

highways <- roads %>% filter(featurecla == "Highway")

# 5. PLOT THE DATA

map_plot <- ggplot() +
    geom_sf(data = world_sf, fill = NA, color = "black") +
    geom_sf(data = highways, color = "red", size = 0.5) +
    coord_sf(crs = "+proj=vandg") +
    theme_minimal() +
    ggtitle("Highways of the World")

# Display the plot
print(map_plot)

# 6. SAVE THE PLOT AS SVG FILE

ggsave("world_highways.svg", plot = map_plot, device = "svg", width = 10, height = 10)
