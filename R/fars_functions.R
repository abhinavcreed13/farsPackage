#' Reads data from Fatality Analysis Reporting System(FARS) file
#'
#' @param filename absolute or relative path of the FARS file
#'
#' @return A Data Frame with FARS file data loaded in memory
#'
#' @note This function requires a valid filename path which should exist
#'       and should be a valid csv, otherwise it will result in error
#'
#' @importFrom readr read_csv
#' @importFrom dplyr tbl_df
#'
#' @examples
#' \dontrun{
#' data <- fars_read(filename="data/accident_2013.csv.bz2")
#' head(data)
#' }
#' @export
fars_read <- function(filename) {
  if(!file.exists(filename))
    stop("file '", filename, "' does not exist")
  data <- suppressMessages({
    readr::read_csv(filename, progress = FALSE)
  })
  dplyr::tbl_df(data)
}

#' Creates a valid FARS filename as per the provided year
#'
#' @param year An integer value for providing year to create corresponding filename
#'
#' @return A character vector with required valid FARS filename for provided year
#'
#' @note This function requires a valid integer value for year, otherwise it will result in error.
#'       For example, this code \code{make_filename("abc")} will break.
#'
#' @examples
#' \dontrun{
#' fars_filename <- make_filename(2013)
#' print(fars_filename)
#' }
#' @export
make_filename <- function(year) {
  year <- as.integer(year)
  sprintf("data/accident_%d.csv.bz2", year)
}

#' Reads data from FARS file for different years to create month-year view
#'
#' @param years A vector with different year values
#'
#' @return A Data Frame List for different provided year values.
#'         Each data frame is mutated with 2 columns view - \code{MONTH} and \code{year}
#'
#' @note This function requires a vector with valid year representing values, otherwise it will result in error.
#'       Also, it will report warning if data is required for year whose file does not exists.
#'
#' @importFrom dplyr mutate select
#'
#' @examples
#' \dontrun{
#' list_data <- fars_read_years(c(2013,2014,2015))
#' print(list_data)
#' }
#' @export
fars_read_years <- function(years) {
  lapply(years, function(year) {
    file <- make_filename(year)
    #print(file)
    tryCatch({
      dat <- fars_read(file)
      dplyr::mutate(dat, year = year) %>%
        dplyr::select(MONTH, year)
    }, error = function(e) {
      warning("invalid year: ", year,e)
      return(NULL)
    })
  })
}

#' Reads data from FARS file for different years to create summarized cleaner data view
#'
#' @param years A vector with different year values
#'
#' @return A Data Frame representing number of fatal injuries spread across different years and corresponding months.
#'         Data frame consists of \code{MONTH} column with provided \code{years} columns
#'         where rows represents the count of fatal injuries occurring in different months
#'
#' @note This function requires a vector with valid year representing values, otherwise it will result in error.
#'       Also, it will report warning if data is required for year whose file does not exists.
#'
#' @importFrom dplyr bind_rows group_by summarize
#' @importFrom tidyr spread
#'
#' @examples
#' \dontrun{
#' summarized_data <- fars_summarize_years(c(2013,2014,2015))
#' head(summarized_data)
#' }
#' @export
fars_summarize_years <- function(years) {
  dat_list <- fars_read_years(years)
  dplyr::bind_rows(dat_list) %>%
    dplyr::group_by(year, MONTH) %>%
    dplyr::summarize(n = n()) %>%
    tidyr::spread(year, n)
}

#' Reads data from FARS file for specific year & plot it's accidents in specific state on map
#'
#' @param state.num An integer value representing state number to plot
#' @param year An integer value representing year to plot
#'
#' @return NULL
#'         It will plot a graphical view of accidents happening in the provided state.
#'
#' @note This function requires a valid integer value for year, otherwise it will result in error.
#'       It also requires a valid integer for representing state number which should be present in data.
#'
#' @importFrom dplyr filter
#' @importFrom maps map
#' @importFrom graphics points
#'
#' @examples
#' \dontrun{
#' fars_map_state(state.num = 4, year=2013)
#' }
#' @export
fars_map_state <- function(state.num, year) {
  filename <- make_filename(year)
  data <- fars_read(filename)
  state.num <- as.integer(state.num)

  if(!(state.num %in% unique(data$STATE)))
    stop("invalid STATE number: ", state.num)
  data.sub <- dplyr::filter(data, STATE == state.num)
  if(nrow(data.sub) == 0L) {
    message("no accidents to plot")
    return(invisible(NULL))
  }
  is.na(data.sub$LONGITUD) <- data.sub$LONGITUD > 900
  is.na(data.sub$LATITUDE) <- data.sub$LATITUDE > 90
  with(data.sub, {
    maps::map("state", ylim = range(LATITUDE, na.rm = TRUE),
              xlim = range(LONGITUD, na.rm = TRUE))
    graphics::points(LONGITUD, LATITUDE, pch = 46)
  })
}
