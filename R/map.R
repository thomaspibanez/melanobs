library(leaflet)
library(readr)

# Herbarium symbol: a teal square
herbarium_svg <- paste0(
  "<svg xmlns='http://www.w3.org/2000/svg' width='22' height='22'>",
  "<rect x='2' y='2' width='18' height='18' fill='#0E6B6F' ",
  "stroke='#F6F8F7' stroke-width='2'/></svg>"
)
herbarium_icon <- makeIcon(
  iconUrl = paste0("data:image/svg+xml;charset=utf-8,",
                   utils::URLencode(herbarium_svg, reserved = TRUE)),
  iconWidth = 22, iconHeight = 22, iconAnchorX = 11, iconAnchorY = 11
)

melanobs_map <- function(dir = ".", height = 520,
                         labels = c("Permanent plots", "Regional herbaria")) {
  plots <- read_csv(file.path(dir, "data/sites.csv"), show_col_types = FALSE)
  herb  <- read_csv(file.path(dir, "data/herbaria.csv"), show_col_types = FALSE)
  leaflet(height = height, options = leafletOptions(minZoom = 3)) |>
    addMapPane("plots", zIndex = 650) |>
    addProviderTiles(providers$Esri.WorldGrayCanvas, group = "Map") |>
    addProviderTiles(providers$Esri.WorldImagery, group = "Satellite") |>
    addMarkers(data = herb, ~lon, ~lat, icon = herbarium_icon,
               popup = ~paste0("<b>", city, "</b><br>", country)) |>
    addCircleMarkers(data = plots, ~lon, ~lat, radius = 8, weight = 1,
                     color = "#16262B", fillColor = "#C98A1B", fillOpacity = 0.9,
                     options = pathOptions(pane = "plots"),
                     popup = ~paste0("<b>", site, "</b><br>", island, ", ", country)) |>
    addLayersControl(baseGroups = c("Map", "Satellite"),
                     options = layersControlOptions(collapsed = FALSE)) |>
    addLegend("bottomleft",
              colors = c("#C98A1B; border-radius:50%", "#0E6B6F; border-radius:0"),
              labels = labels, opacity = 1) |>
    setView(lng = 168, lat = -15, zoom = 4)
}