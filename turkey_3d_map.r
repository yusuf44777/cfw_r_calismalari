# 1. LIBRARIES
#-------------

install.packages("pacman")
pacman::p_load(
    terra,
    elevatr,
    sf,
    geodata,
    tidyverse,
    rayshader
)

# 2. COUNTRY BORDERS
#-------------------

path <- getwd()

country_sf <- geodata::gadm(
    country = "TR",
    level = 0,
    path = path
) |>
    sf::st_as_sf()

# 3. DOWNLOAD RIVERS
#-------------------

#url <- "https://data.hydrosheds.org/file/HydroRIVERS/HydroRIVERS_v10_eu_shp.zip"
#destfile <- basename(url)

#download.file(
#    url = url,
#    destfile = destfile,
#    mode = "wb"
#)

#unzip(destfile)

# 4. LOAD RIVERS
#---------------

filename <- list.files(
    path = "HydroRIVERS_v10_eu_shp",
    pattern = ".shp",
    full.names = TRUE
)

country_bbox <- sf::st_bbox(country_sf)


# xmin      ymin      xmax      ymax
#  5.956063 45.817059 10.495112 47.808483

bbox_wkt <- "POLYGON((
    25.66514 35.81543,
    25.66514 42.10666,
    44.83499 42.10666,
    44.83499 35.81543,
    25.66514 35.81543
))"

country_rivers <- sf::st_read(
    filename,
    wkt_filter = bbox_wkt
) |>
    sf::st_intersection(
        country_sf
    )

plot(sf::st_geometry(country_rivers))

# 5. RIVER WIDTH
#---------------

sort(
    unique(
        country_rivers$ORD_FLOW
    )
)

crs_country <- "+proj=lcc +lat_0=52 +lon_0=10 +lat_1=35 +lat_2=65 +x_0=4000000 +y_0=2800000 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs +type=crs"

country_river_width <- country_rivers |>
    dplyr::mutate(
        width = as.numeric(
            ORD_FLOW
        ),
        width = dplyr::case_when(
            width == 3 ~ 9, 
            width == 4 ~ 7,
            width == 5 ~ 5,
            width == 6 ~ 3,
            width == 7 ~ 1,
            TRUE ~ 0
        )
    ) |>
    sf::st_as_sf() |>
    sf::st_transform(crs = crs_country)

# 6. DEM
#-------

dem <- elevatr::get_elev_raster(
    locations = country_sf,
    z = 5, clip = "locations"
)

dem_country <- dem |>
    terra::rast() |>
    terra::project(crs_country)

dem_matrix <- rayshader::raster_to_matrix(
    dem_country
)

#----------------

dem_matrix |>
    rayshader::height_shade(
        texture = colorRampPalette(
            c(
                "#fcc69f",
                "#c67847"
            )
        )(128)
    ) |>
    rayshader::add_overlay(
        rayshader::generate_line_overlay(
            geometry = country_river_width,
            extent = dem_country,
            heightmap = dem_matrix,
            color = "#387B9C",
            linewidth = country_river_width$width,
            data_column_width = "width"
        ), alphalayer = 1
    ) |>
    rayshader::plot_3d(
        dem_matrix,
        zscale = 20,
        solid = FALSE,
        shadow = TRUE,
        shadow_darkness = 1,
        background = "white",
        windowsize = c(600, 600),
        zoom = .5,
        phi = 89,
        theta = 0
    )


rayshader::render_camera(
    zoom = .75
)

# 8. RENDER OBJECT
#-----------------

u <- "https://dl.polyhaven.org/file/ph-assets/HDRIs/hdr/4k/photo_studio_loft_hall_4k.hdr"
hdri_file <- basename(u)

download.file(
    url = u,
    destfile = hdri_file,
    mode = "wb"
)

file_name <- "turkey-3d-elevation-rivers.png"

rayshader::render_highquality(
    filename = file_name,
    preview = TRUE,
    light = FALSE,
    environment_light = hdri_file,
    intensity_env = 1,
    interactive = FALSE,
    width = 3000,
    height = 3000
)
