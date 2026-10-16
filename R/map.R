library(leaflet)
library(readr)

melanobs_map <- function(dir = ".", height = 520,
                         labels = c("Permanent plots (examples)", "Regional herbaria")) {
  plots <- read_csv(file.path(dir, "data/sites.csv"), show_col_types = FALSE)
  herb  <- read_csv(file.path(dir, "data/herbaria.csv"), show_col_types = FALSE)
  leaflet(height = height, options = leafletOptions(minZoom = 3)) |>
    addProviderTiles(providers$Esri.WorldGrayCanvas, group = "Map") |>
    addProviderTiles(providers$Esri.WorldImagery, group = "Satellite") |>
    addCircleMarkers(data = plots, ~lon, ~lat, radius = 8, weight = 1,
                     color = "#16262B", fillColor = "#C98A1B", fillOpacity = 0.9,
                     popup = ~paste0("<b>", site, "</b><br>", country)) |>
    addCircleMarkers(data = herb, ~lon, ~lat, radius = 8, weight = 1,
                     color = "#16262B", fillColor = "#0E6B6F", fillOpacity = 0.9,
                     popup = ~paste0("<b>", city, "</b><br>", country)) |>
    addLayersControl(baseGroups = c("Map", "Satellite"),
                     options = layersControlOptions(collapsed = FALSE)) |>
    addLegend("bottomleft", colors = c("#C98A1B", "#0E6B6F"),
              labels = labels, opacity = 1) |>
    setView(lng = 168, lat = -15, zoom = 4)
}