% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/single_storm_track.R
\name{single_storm_track}
\alias{single_storm_track}
\title{single_storm_track}
\usage{
single_storm_track(
  map_in,
  nerr_site_id = NULL,
  storm_nm = NULL,
  storm_rank = NULL,
  stations = NULL,
  bbox = NULL,
  path_to_shp = NULL,
  path_to_base = NULL,
  lab_loc = NULL,
  scale_pos = "bottomleft",
  skip = NULL
)
}
\arguments{
\item{map_in}{.xlsx with all required input variables defined (string).}

\item{nerr_site_id}{3 digit reserve code (string)}

\item{storm_nm}{name of storm event (string).}

\item{storm_rank}{numeric rank of storm for plotting aesthetics. a single storm with rank = 1 will be emphasized. (numeric integer)}

\item{stations}{comma separated list of stations to plot on map (string)}

\item{bbox}{comma separated bounding box for map extents (string vector )}

\item{path_to_shp}{pathway to shapefile for each storm track (string)}

\item{path_to_base}{pathway to shapefile for the basemap world boundaries (string)}

\item{lab_loc}{location of labels on the map. optional (string).}

\item{scale_pos}{location of the scale on th map optional (string)}

\item{skip}{TRUE/FALSE. If TRUE, function will be skipped (string).}
}
\value{
map is generated and saved in /output/maps/
}
\description{
single_storm_track
}
\examples{

\dontrun{
#StormTrackVariables.xlsx is a template variable input file saved in data/
var_in <- 'data/StormTrackVariables.xlsx'
single_storm_track(map_in = var_in)
}
}
