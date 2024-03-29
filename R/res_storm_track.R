#' res_storm_track
#'
#' @param nerr_site_id 3 digit reserve code (string).
#' @param stations comma separated list of stations to locate on map (string).
#' @param bbox comma separated bounding box for map extents (string vector )
#' @param path_to_shp pathway to shapefile for the reserve boundary (string)
#' @param lab_loc location of labels on the map. optional (string).
#' @param scale_pos location of the scale on th map optional (string)
#' @param map_in .xlsx with all required input variables defined (string).
#' @param storm_nm name of storm event (string).
#'
#'
#' @return map is generated and saved in /output/maps/
#' @export
#'
#' @examples
#' \dontrun{
#' #StormTrackVariables.xlsx is a template variable input file saved in data/
#' var_in <- 'data/StormTrackVariables.xlsx'
#' res_storm_track(map_in = var_in)
#' }
res_storm_track <- function(map_in
                            , nerr_site_id = NULL
                            , storm_nm = NULL
                            , stations = NULL
                            , bbox = NULL
                            , path_to_shp = NULL
                            , lab_loc = NULL
                            , scale_pos = 'bottomleft') {


  # ----------------------------------------------------------------------------
  # Define global variables
  # ----------------------------------------------------------------------------
  LABEL_ <- rlang::sym('LABEL')



  # ----------------------------------------------------------------------------
  # Read in Data
  # ----------------------------------------------------------------------------

  #a.  Read in the variable input template, var_in

  input_Parameters <- openxlsx::read.xlsx(map_in, sheet = "Parameters")
  input_Shp <- openxlsx::read.xlsx(map_in, sheet = "shps")
  input_Stations <- openxlsx::read.xlsx(map_in, sheet = "Stations")


  if(is.null(nerr_site_id)) nerr_site_id <- input_Parameters[1,2]
  if(is.null(stations)) stations <- input_Stations$stations[!is.na(input_Stations$stations)]
  if(is.null(bbox)) bbox <- input_Stations$bbox[!is.na(input_Stations$bbox)]
  if(is.null(storm_nm)) storm_nm <- input_Shp$storm_nm[!is.na(input_Shp$storm_nm)]
  if(is.null(path_to_shp)) path_to_shp <- input_Shp$path[!is.na(input_Shp$path)]

  #b. Generate location labels
  loc <- get('sampling_stations')
  loc <- loc[(loc$Station.Code %in% stations), ]
  loc$abbrev <- toupper(substr(loc$Station.Code, start = 4, stop = 5))

  #c. Read data as shapefiles

  for(i in 1:length(path_to_shp)) {

    temp <- sf::st_read(path_to_shp[i]) %>%
      sf::st_set_crs(4326) %>%
      dplyr::mutate(NAME = storm_nm[i])
    temp <-
      dplyr::mutate(LABEL = c(storm_nm[i], rep("",nrow(temp)-1)))

    ifelse(i == 1, shps <- temp, shps <- rbind(shps,temp))

  }

  #d. Set leaflet colors
  colors <- seq(1, length(path_to_shp))
  colors <- grDevices::colorRampPalette(c("#df4d4d", "#f2d17e","#426144"))(length(colors))
  colordf <- data.frame(colors = colors, NAME = storm_nm)
  shps <- shps %>%
    dplyr::left_join(colordf, by="NAME")

  #e. filter for track labels
  labs <- shps %>%
    dplyr::filter(!! LABEL_ != "")


  #e. Determine if r and l labs exist <- need to figure out if we need this for this map... borrowed from res_local_map
  #if(!is.null(lab_loc)){
  #  if('L' %in% lab_loc){left_labs <- grep('L', lab_loc)}
  #  if('R' %in% lab_loc){right_labs <- grep('R', lab_loc)}
  #} else {
  #  #default to left labels
  #  left_labs <- c(1:4)
  #}

  #f. set map label styles
  label_style <- list(
    "box-shadow" = "none",
    "border-radius" = "5px",
    "font" = "bold 16px/1.5 'Helvetica Neue', Arial, Helvetica, sans-serif",
    "padding" = "1px 5px 1px 5px"
  )


  # Plot map
  m <- leaflet::leaflet(loc, options = leafletOptions(zoomControl = FALSE), width = 500, height = 500) %>%
    addProviderTiles(leaflet::providers$Esri.WorldGrayCanvas) %>%  # Add default OpenStreetMap map tiles, CartoDB.Positron
    addPolylines(data = shps,
                 weight = 2,
                 color = shps$colors,
                 opacity = 1) %>%
    addPolylines(data = labs,
                 opacity = 0,
                 color = labs$colors,
                 label = labs$LABEL,
                 labelOptions = labelOptions(noHide=T
                                             , textOnly = T
                                             , direction = c('left')
                                             , opacity = 1
                                             , offset = c(5, 10)
                                             , style = label_style))


  #add station labels
  m <- m %>%
    addCircleMarkers(lng = ~Longitude*-1, lat = ~Latitude, radius = 5
                     , weight = 0, fillOpacity = 1
                     , color = loc$color
                     , label = loc$abbrev
                     , labelOptions = labelOptions(noHide = c(T,F)
                                                   , direction = c('left')
                                                   , opacity = 1
                                                   , offset = c(-5, 0)
                                                   , style = label_style))
  #add scale and update extent
  m <- m %>%
    addScaleBar(position = scale_pos) %>%
    fitBounds(bbox[1], bbox[2], bbox[3], bbox[4])


  #save output
  mapview::mapshot(m, paste0("output/maps/Stormtrack_",paste(storm_nm, collapse="_"),"_",paste(stations, collapse="_"), ".html"))

  return(m)

}
