% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/res_storm_track.R
\name{res_storm_track}
\alias{res_storm_track}
\title{res_storm_track}
\usage{
res_storm_track(
  map_in,
  nerr_site_id = NULL,
  storm_nm = NULL,
  stations = NULL,
  bbox = NULL,
  path_to_shp = NULL,
  lab_loc = NULL,
  scale_pos = "bottomleft"
)
}
\arguments{
\item{map_in}{.xlsx with all required input variables defined (string).}

\item{nerr_site_id}{3 digit reserve code (string).}

\item{storm_nm}{name of storm event (string).}

\item{stations}{comma separated list of stations to locate on map (string).}

\item{bbox}{comma separated bounding box for map extents (string vector )}

\item{path_to_shp}{pathway to shapefile for the reserve boundary (string)}

\item{lab_loc}{location of labels on the map. optional (string).}

\item{scale_pos}{location of the scale on th map optional (string)}
}
\value{
map is generated and saved in /output/maps/
}
\description{
res_storm_track
}
\examples{
\dontrun{
#StormTrackVariables.xlsx is a template variable input file saved in data/
var_in <- 'data/StormTrackVariables.xlsx'
res_storm_track(map_in = var_in)
}
}
