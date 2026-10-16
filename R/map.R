library(leaflet)
library(readr)

read_plots    <- function(dir = ".") read_csv(file.path(dir, "data/plots.csv"), show_col_types = FALSE)
read_herbaria <- function(dir = ".") read_csv(file.path(dir, "data/herbaria.csv"), show_col_types = FALSE)

# Link to the dedicated page of a plot or herbarium, relative to the current page
# (dir is the path from the current page to the site root, e.g. "." or "..")
item_link <- function(dir, folder, slug, text) {
  paste0("<a href='", file.path(dir, folder, paste0(slug, ".html")), "'>", text, "</a>")
}

# focus: slug of a plot or herbarium to centre the map on (for dedicated pages)
melanobs_map <- function(dir = ".", height = 520,
                         labels = c("Permanent plots", "Regional herbaria"),
                         more = "More &rarr;", focus = NULL, zoom = 9) {
  plots <- read_plots(dir)
  herb  <- read_herbaria(dir)
  m <- leaflet(height = height, options = leafletOptions(minZoom = 3)) |>
    addProviderTiles(providers$Esri.WorldGrayCanvas, group = "Map") |>
    addProviderTiles(providers$Esri.WorldImagery, group = "Satellite") |>
    addCircleMarkers(data = herb, ~lon, ~lat, radius = 11, weight = 1,
                     color = "#16262B", fillColor = "#0E6B6F", fillOpacity = 0.5,
                     popup = ~paste0("<b>", herbarium, "</b><br>", city, ", ", country,
                                     "<br>", item_link(dir, "herbaria", slug, more))) |>
    addCircleMarkers(data = plots, ~lon, ~lat, radius = 7, weight = 1,
                     color = "#16262B", fillColor = "#C98A1B", fillOpacity = 0.6,
                     popup = ~paste0("<b>", site, "</b><br>", island, ", ", country,
                                     "<br>", item_link(dir, "plots", slug, more))) |>
    addLayersControl(baseGroups = c("Map", "Satellite"),
                     options = layersControlOptions(collapsed = FALSE)) |>
    addLegend("bottomleft", colors = c("#C98A1B", "#0E6B6F"),
              labels = labels, opacity = 1)
  if (is.null(focus)) return(setView(m, lng = 168, lat = -15, zoom = 4))
  item <- rbind(plots[plots$slug == focus, c("lon", "lat")],
                herb[herb$slug == focus, c("lon", "lat")])
  if (nrow(item) != 1) stop("Unknown plot or herbarium: ", focus)
  setView(m, lng = item$lon, lat = item$lat, zoom = zoom)
}

# Key facts table for a dedicated page
plot_facts <- function(slug, dir = "..") {
  p <- read_plots(dir)
  p <- p[p$slug == slug, ]
  knitr::kable(data.frame(c("Country", "Island", "Latitude", "Longitude"),
                          c(p$country, p$island, p$lat, p$lon)),
               col.names = c("", ""))
}

herbarium_facts <- function(slug, dir = "..") {
  h <- read_herbaria(dir)
  h <- h[h$slug == slug, ]
  knitr::kable(data.frame(c("Code", "City", "Country", "Latitude", "Longitude"),
                          c(h$herbarium, h$city, h$country, round(h$lat, 5), round(h$lon, 5))),
               col.names = c("", ""))
}
