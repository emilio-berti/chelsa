#' @title Calculate Lower Quarter
#' @param x matrix n x 12 (months).
#' @return matrix n x 2:
#'   the first column is the value, 
#'   the second column the first calendar month of the quarter.
cppFunction(
  '
  NumericMatrix lowest_quarter ( NumericMatrix x ) {
    
    int rows = x.nrow();
    int cols = x.ncol();
    double val;
    double window;
    NumericMatrix ans(rows, 2); //return matrix

    for (int i = 0 ; i < rows ; i++) {
      for (int j = 0 ; j < (cols - 2) ; j++) {
        window = x(i, j) + x(i, j + 1) + x(i, j + 2);
        if (window < val || j == 0) {
          val = window;
          ans(i, 1) = j;
        }
      }
      ans(i, 0) = val;
    }

    return ans;
  }
'
)
#' @title Calculate Highest Quarter
#' @param x matrix n x 12 (months).
#' @return matrix n x 2:
#'   the first column is the value, 
#'   the second column the first calendar month of the quarter.
cppFunction(
  '
  NumericMatrix highest_quarter ( NumericMatrix x ) {
    
    int rows = x.nrow();
    int cols = x.ncol();
    double val;
    double window;
    NumericMatrix ans(rows, 2); //return matrix

    for (int i = 0 ; i < rows ; i++) {
      for (int j = 0 ; j < (cols - 2) ; j++) {
        window = x(i, j) + x(i, j + 1) + x(i, j + 2);
        if (window > val || j == 0) {
          val = window;
          ans(i, 1) = j;
        }
      }
      ans(i, 0) = val;
    }

    return ans;
  }
'
)

#' @title Reorder Files Monthly
#' @param files vector of file locations.
#' @return the same vector, but ordered by month.
order_files <- function(files) {
  ff <- sapply(files, strsplit, "/", USE.NAMES = FALSE)
  ff <- sapply(ff, function(x) x[grep("CHELSA", x)], USE.NAMES = FALSE)
  ff <- gsub("^[A-Za-z_]+", "", ff)
  ff <- gsub("[A-Za-z_]+$", "", ff)
  ff <- gsub("_[0-9]+_V.2.1.", "", ff)
  ord <- order(as.numeric(ff))
  return (files[ord])
}

#' @title Annual Total Precipitation BIO12
#' @param files vector of file locations.
#' @return SpatRaster with annual precipitation, in kg/m^2.
bio12 <- function(files) {
  r <- rast(files)
  ans <- sum(r, na.rm = TRUE)
  names(ans) <- "BIO12"
  return (ans)
}

#' @title Quarter Based Bioclim
#' @param r SpatRaster of the variable of interest.
#' @param stat string of the statistic to calculates 
#'   "lowest" for driest/coldest quarter,
#'   "highest" for wettest/warmest quarter.
#' @return SpatRaster.
quarter <- function(files, stat) {
  stopifnot(stat %in% c("lowest", "highest"))
  r <- rast(files)
  vals <- values(r)
  stopifnot(ncell(ans) == nrow(vals))
  ans <- c(r[[1]], r[[1]])
  if (stat == "lowest") {
    stat <- lowest_quarter(vals)
  } else {
    stat <- highest_quarter(vals)
  }
  values(ans) <- stat
  names(ans) <- c("value", "starting month")
  return (ans)
}

#' @title Annual Mean Temperature BIO1
#' @param files vector of file locations.
#' @return SpatRaster with annual precipitation, in K / 10.
bio01 <- function(files) {
  r <- rast(files)
  ans <- mean(r, na.rm = TRUE)
  names(ans) <- "BIO01"
  return (ans)
}