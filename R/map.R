library(leaflet)
library(readr)

read_plots    <- function(dir = ".") read_csv(file.path(dir, "data/plots.csv"), show_col_types = FALSE)
read_herbaria <- function(dir = ".") read_csv(file.path(dir, "data/herbaria.csv"), show_col_types = FALSE)

# Coordinates as displayed in tables (always 4 decimals)
coord <- function(x) formatC(x, format = "f", digits = 4)

# Link to the dedicated page of a plot or herbarium, relative to the current page
# (dir is the path from the current page to the site root, e.g. "." or "..")
item_link <- function(dir, folder, slug, text) {
  paste0("<a href='", file.path(dir, folder, paste0(slug, ".html")), "'>", text, "</a>")
}

# focus: slug of a plot or herbarium to centre the map on (for dedicated pages)
# show: which layers to draw, "plots" and/or "herbaria"
melanobs_map <- function(dir = ".", height = 520,
                         labels = c("Permanent plots", "Herbaria"),
                         more = "More &rarr;", focus = NULL, zoom = 9,
                         show = c("plots", "herbaria")) {
  plots <- read_plots(dir)
  herb  <- read_herbaria(dir)
  m <- leaflet(height = height, options = leafletOptions(minZoom = 3)) |>
    addProviderTiles(providers$Esri.WorldGrayCanvas, group = "Map") |>
    addProviderTiles(providers$Esri.WorldImagery, group = "Satellite")
  if ("herbaria" %in% show)
    m <- addCircleMarkers(m, data = herb, ~lon, ~lat, radius = 11, weight = 1,
                          color = "#16262B", fillColor = "#0E6B6F", fillOpacity = 0.5,
                          popup = ~paste0("<b>", name, "</b><br>", code, " &middot; ", city, ", ", country,
                                          "<br>", item_link(dir, "herbaria", slug, more)))
  if ("plots" %in% show)
    m <- addCircleMarkers(m, data = plots, ~lon, ~lat, radius = 7, weight = 1,
                          color = "#16262B", fillColor = "#C98A1B", fillOpacity = 0.6,
                          popup = ~paste0("<b>", site, "</b><br>", island, ", ", country,
                                          "<br>", item_link(dir, "plots", slug, more)))
  shown <- c("plots", "herbaria") %in% show
  m <- m |>
    addLayersControl(baseGroups = c("Map", "Satellite"),
                     options = layersControlOptions(collapsed = FALSE)) |>
    addLegend("bottomleft", colors = c("#C98A1B", "#0E6B6F")[shown],
              labels = labels[shown], opacity = 1)
  if (is.null(focus)) {
    # Zoom to fit all shown sites, whatever the screen size
    pts <- rbind(if ("plots" %in% show) plots[, c("lon", "lat")],
                 if ("herbaria" %in% show) herb[, c("lon", "lat")])
    return(fitBounds(m, min(pts$lon), min(pts$lat), max(pts$lon), max(pts$lat),
                     options = list(padding = c(30, 30))))
  }
  item <- rbind(plots[plots$slug == focus, c("lon", "lat")],
                herb[herb$slug == focus, c("lon", "lat")])
  if (nrow(item) != 1) stop("Unknown plot or herbarium: ", focus)
  setView(m, lng = item$lon, lat = item$lat, zoom = zoom)
}

# Key facts table for a dedicated page
plot_facts <- function(slug, dir = "..") {
  p <- read_plots(dir)
  p <- p[p$slug == slug, ]
  # pi_local = "no" marks plots whose PI is not a local partner
  pi_local <- is.na(p$pi_local) || p$pi_local != "no"
  facts <- data.frame(c("Country", "Island", "Latitude", "Longitude",
                         "Elevation (approx.)", "Substrate", "Established",
                         "Local contact",
                         if (pi_local) "Local principal investigator" else "Principal investigator"),
                       c(p$country, p$island, coord(p$lat), coord(p$lon),
                         paste(p$elevation, "m"), p$substrate, p$established,
                         p$contact, p$pi))
  # Rows without a value yet (e.g. plots not described) are left out
  facts <- facts[!is.na(facts[[2]]) & facts[[2]] != "", ]
  knitr::kable(facts, col.names = c("", ""), row.names = FALSE)
}

herbarium_facts <- function(slug, dir = "..") {
  h <- read_herbaria(dir)
  h <- h[h$slug == slug, ]
  facts <- data.frame(c("Code", "City", "Country", "Latitude", "Longitude", "Curator"),
                       c(h$code, h$city, h$country, coord(h$lat), coord(h$lon),
                         h$curator))
  # Rows without a value yet are left out
  facts <- facts[!is.na(facts[[2]]) & facts[[2]] != "", ]
  knitr::kable(facts, col.names = c("", ""), row.names = FALSE)
}
