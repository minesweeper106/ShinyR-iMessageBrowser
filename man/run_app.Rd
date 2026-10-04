% Please edit documentation in R/run_app.R
\name{run_app}
\alias{run_app}
\title{Run the iMessage Browser app}
\usage{
run_app(launch.browser = TRUE, ...)
}
\arguments{
\item{launch.browser}{Open the app in the default web browser.
Passed to \code{\link[shiny:runApp]{shiny::runApp()}}.}

\item{...}{Further arguments passed to \code{\link[shiny:runApp]{shiny::runApp()}}, e.g. \code{port}.}
}
\value{
Called for its side effect of running the app.
}
\description{
Starts the Shiny app locally. Files you select are read on your own
machine and nothing is uploaded anywhere.
}
