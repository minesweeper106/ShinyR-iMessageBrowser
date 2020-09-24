datacalc <- function(u){ 
  
  data <- as.character(as.POSIXct(u ,tz = "", origin = "1970-01-01", tryFormats = c(
    "%Y-%m-%d %H:%M:%OS",
    "%Y/%m/%d %H:%M:%OS",
    "%Y-%m-%d %H:%M",
    "%Y/%m/%d %H:%M",
    "%Y-%m-%d",
    "%Y/%m/%d"), optional = FALSE ))
}
