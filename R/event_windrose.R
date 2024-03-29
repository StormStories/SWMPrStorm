#' event_windrose
#'
#' @param var_in .xlsx with all required input variables defined (string).
#' @param data_path pathway to cdmo data folder (string).
#' @param storm_start YYYY-MM-DD HH:MM:SS (string).
#' @param storm_end YYYY-MM-DD HH:MM:SS end of storm event (string).
#' @param met_sites comma separated list of station codes (string)
#' @param keep_flags comma separated list of data quality flags that should be kept (string).
#' @param reserve 3 digit reserve code (string).
#' @param skip TRUE/FALSE. If TRUE, function will be skipped (string).
#' @param user_units English, or SI (string)
#'
#' @return plots are generated and saved in /output/met/windrose/
#' @export
#'
#' @examples
#'
#' \dontrun{
#' #StormVariables.xlsx is a template variable input file saved in data/
#' vars_in <- 'data/StormTrackVariables.xlsx'
#' single_storm_track(var_in = vars_in)
#' }
event_windrose <- function(var_in,
                           data_path = NULL,
                           reserve = NULL,
                           storm_start = NULL,
                           storm_end = NULL,
                           met_sites = NULL,
                           keep_flags = NULL,
                           skip = NULL,
                           user_units = NULL) {


  # ----------------------------------------------------------------------------
  # Define global variables
  # ----------------------------------------------------------------------------
  NERR.Site.ID_ <- rlang::sym('NERR.Site.ID')
  Status_ <- rlang::sym('Status')
  Station.Type_ <- rlang::sym('Station.Type')


  # ----------------------------------------------------------------------------
  # Read in Data
  # ----------------------------------------------------------------------------

  #a.  Read in the variable input template, var_in

  input_Parameters <- openxlsx::read.xlsx(var_in, sheet = "windrose")
  input_Master <- openxlsx::read.xlsx(var_in, sheet = "MASTER")


  #b.  Read the following variables from template spreadsheet if not provided as optional arguments

  if(is.null(reserve)) reserve <- input_Master[1,2]


  stations <- get('sampling_stations') %>%
    dplyr::filter(!! NERR.Site.ID_ == reserve) %>%
    dplyr::filter(!! Status_ == "Active")

  met_stations <- stations %>%
    dplyr::filter(!! Station.Type_ == 0)

  if(is.null(storm_start)) storm_start <- input_Parameters[1,2]
  if(is.null(storm_end)) storm_end <- input_Parameters[2,2]
  #if(is.null(met_sites)) met_sites <- unlist(strsplit(input_Parameters[3,2],", "))
  if(is.null(met_sites)) met_sites <- if(is.na(input_Parameters[3,2])) {met_stations$Station.Code} else {unlist(strsplit(input_Parameters[3,2],", "))}
  if(is.null(keep_flags)) keep_flags <- unlist(strsplit(input_Parameters[4,2],", "))
  if(is.null(skip)) skip <- input_Parameters[5,2]
  if(is.null(user_units)) user_units <- input_Parameters[6,2]
  if(is.null(data_path)) data_path <- 'data/cdmo'


  ############## Tests #########################################################
  if(skip == "TRUE") {return(warning("skip set to 'TRUE', skipping event_windrose"))}



  # ----------------------------------------------
  # Load water quality data ----------------------
  # ----------------------------------------------

  ## load, clean, and filter data

  data_type <- 'met'

  ls_par <- lapply(met_sites, SWMPr::import_local, path = data_path)
  ls_par <- lapply(ls_par, SWMPr::qaqc, qaqc_keep = keep_flags)
  ls_par <- lapply(ls_par, subset, subset = c(storm_start, storm_end))

  ## convert dataset to user defined units (if "SI", no conversion will take place)
  ls_par <- SWMPrStorm::convert_units(ls_par, user_units)

  names(ls_par) <- met_sites


  # ----------------------------------------------
  # Wind rose                                  ---
  # ----------------------------------------------

  angle = 45
  width = 1.5
  breaks = 8
  paddle = FALSE
  grid.line = 20
  max.freq = 90
  cols = 'GnBu'
  annotate = FALSE
  main = NULL
  type = 'default'
  between = list(x = 1, y = 1)
  par.settings = NULL
  strip = NULL


  for (i in 1:length(names(ls_par))) {
    tmp <- ls_par[[i]]
    tmp$date_char <- as.character(as.Date(tmp$datetimestamp))


    plt_ttl <- paste0("output/met/windrose/",attributes(tmp)$station, "_wspd.png")
    grDevices::png(plt_ttl, width = 1000, height = 1000)
    z <- openair::windRose(tmp, ws = 'wspd', wd = 'wdir', #type = 'date_char',
                      angle = angle,
                      width = width,
                      breaks = breaks,
                      paddle = paddle,
                      grid.line = grid.line,
                      max.freq = 60, #max.freq,
                      cols = cols,
                      annotate = annotate,
                      main = main,
                      # type = type,
                      between = between,
                      par.settings = par.settings,
                      strip = strip,
                      auto.text = FALSE)
    if(user_units == "English") {z$plot$legend$bottom$args$key$footer <- "(mph)"}
    z
    grDevices::dev.off()


    plt_ttl <- paste0("output/met/windrose/",attributes(tmp)$station, "_wspd_bydate.png")
    grDevices::png(plt_ttl, width = 1000, height = 1000)
    z <- openair::windRose(tmp, ws = 'wspd', wd = 'wdir', type = 'date_char',
                      angle = angle,
                      width = width,
                      breaks = breaks,
                      paddle = paddle,
                      grid.line = grid.line,
                      max.freq = max.freq,
                      cols = cols,
                      annotate = annotate,
                      main = main,
                      # type = type,
                      between = between,
                      par.settings = par.settings,
                      strip = strip)
    if(user_units == "English") {z$plot$legend$bottom$args$key$footer <- "(mph)"}
    z
    grDevices::dev.off()

  }

}



