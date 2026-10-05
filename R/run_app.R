#' Run the iMessage Browser app
#'
#' Starts the Shiny app locally. Files you select are read on your own
#' machine and nothing is uploaded anywhere.
#'
#' @param launch.browser Open the app in the default web browser.
#'   Passed to [shiny::runApp()].
#' @param ... Further arguments passed to [shiny::runApp()], e.g. `port`.
#' @return Called for its side effect of running the app.
#' @export
run_app <- function(launch.browser = TRUE, ...) {
  shiny::addResourcePath("imb-assets", system.file("app/www", package = "imessagebrowser"))
  # message databases can be large (default Shiny limit is 5 MB)
  old <- options(shiny.maxRequestSize = 20 * 1024^2)
  on.exit(options(old), add = TRUE)
  app <- shiny::shinyApp(ui = app_ui(), server = app_server)
  shiny::runApp(app, launch.browser = launch.browser, ...)
}

