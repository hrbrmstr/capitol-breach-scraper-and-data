# Setup GH Action R pkg cache dir

.libPaths("cache")

# figure out what isn't cached
needed <- c("stringi", "rvest", "lubridate", "jsonlite", "purrr", "magrittr", "tibble", "tidyr", "dplyr")
cached <- list.files("./cache")

to_resintall <- setdiff(needed, cached)

# reinstall if any not there
if (length(to_reinstall) > 0L) {
  install.packages(
    pkgs = to_reinstall,
    lib = path.expand("./cache"),
    dependencies = c("Depends", "Imports", "LinkingTo")
  )
}

# go about business as usual
library(stringi, include.only = c("stri_split_regex", "stri_match_first_regex", "stri_trans_totitle"))
library(rvest, include.only = c("read_html", "html_nodes", "html_node", "html_text"))
library(lubridate, include.only = c("year", "round_date", "parse_date_time", "year<-"))
library(jsonlite, include.only = c("stream_out"))
library(purrr, include.only = c("map", "map2", "set_names"))
library(magrittr, include.only = c("%>%"))
library(tibble, include.only = c("tibble"))
library(tidyr, include.only = c("separate"))
library(dplyr, include.only = c("mutate"))

today <- as.character(Sys.Date())

output_file <- path.expand(sprintf("docs/%s.json", today))
latest_file <- path.expand("docs/latest.txt")

latest_url <- sprintf("https://hrbrmstr.github.io/capitol-breach-scraper-and-data/%s.json", today)

# get the DoJ Capitol Breach Cases page
pg <- read_html("https://www.justice.gov/usao-dc/capitol-breach-cases")

# and the main table where the info is
tbl <- html_node(pg, xpath = ".//table[@data-tablesaw-mode]")

# extract case number
html_nodes(tbl, xpath = ".//td[1]") %>%
  html_text(trim = TRUE) -> case_num

# extract suspect name
html_nodes(tbl, xpath = ".//td[2]") %>%
  html_text(trim = TRUE) -> name

# extract DoJ link to the suspect case
html_nodes(tbl, xpath = ".//td[2]/a/@href") %>%
  html_text(trim = TRUE) %>%
  sprintf("https://www.justice.gov%s", .) -> case_link

# extract the charges
html_nodes(tbl, xpath = ".//td[3]") %>%
  html_text(trim = TRUE) %>%
  stri_split_regex(
    pattern = ";[[:space:]]*|\n+",
    multiline = TRUE
  ) -> charges

# extract the case documents lists
map2(
  html_nodes(tbl, xpath = ".//td[4]") %>%
    map(html_nodes, xpath = ".//a/@href") %>%
    map(html_text),
  html_nodes(tbl, xpath = ".//td[4]") %>%
    map(html_nodes, xpath = ".//a") %>%
    map(html_text),
  ~as.list(set_names(.x, .y))
) -> case_doc_links

# extract suspect location
html_nodes(tbl, xpath = ".//td[5]") %>%
  html_text(trim = TRUE) -> location

# extract the entire status field (we'll grab the first action date below)
html_nodes(tbl, xpath = ".//td[6]") %>%
  html_text(trim = TRUE) -> full_status

# ugly code to get the first arrested|charged|indicted|surrendered action
# get slashed-dates
html_nodes(tbl, xpath = ".//td[6]") %>%
  html_text(trim = TRUE) %>%
  stri_match_first_regex(
    pattern =
      "
(?:arrest|charge|indict|surrendered)                 # one of these keywords
[^[:digit:]]+                                        # ignore until digit
(
  # order is important
  [[:digit:]]{1,2}/[[:digit:]]{1,2}/[[:digit:]]{1,4} # m/d/yyyy
  |
  [[:digit:]]{1,2}/[[:digit:]]{1,2}/[[:digit:]]{1,2} # m/d/yy
  |
  [[:digit:]]{1,2}/[[:digit:]]{1,2}                  # m/dd
)
",
    case_insensitive = TRUE,
    comments = TRUE
  ) %>%
  .[,2] -> d1

# get verbose dates
html_nodes(tbl, xpath = ".//td[6]") %>%
  html_text(trim = TRUE) %>%
  stri_match_first_regex(
    pattern =
      "
(?:arrest|charge|indict|surrendered) # one of these keywords
.*
(
  # month d, yyyy
  # month dd, yyyy
  (?:january|february|march|april|june|july|august|september|october|november|december|jan|feb|mar|apr|may|jun|jul|aug|sep|nov|dec)
  [[:space:]]+
  [[:digit:]]{1,2},
  [[:space:]]+
  [[:digit:]]{2,4}
  |
  # month d
  # month dd
  (?:january|february|march|april|june|july|august|september|october|november|december|jan|feb|mar|apr|may|jun|jul|aug|sep|nov|dec)
  [[:space:]]+
  [[:digit:]]{1,2}
)
",
  case_insensitive = TRUE,
  comments = TRUE
  ) %>%
  .[,2] -> d2

# combine (replace NA slash date with verbose) and make a real date
as.Date(
  parse_date_time(
    ifelse(is.na(d1), d2, d1),
    orders = c("mdY", "mdy", "md")
  )
) -> first_date

# fix `0000` dates
year(first_date[!is.na(first_date) & year(first_date) == 0]) <- 2021
# fix DoJ year data entry issue (added 2021-08-18)
year(first_date[name == "BLACK, Joshua Matthew"]) <- 2021

# make a nice data frame
tibble(
  case_num,
  case_link,
  name,
  charges,
  case_doc_links,
  location,
  first_date,
  full_status
) %>%
  separate(
    location, c("state", "muni"), sep = ",[[:space:]]+", fill = "right"
  ) %>%
  mutate(
    state = stri_trans_totitle(state),
    first_date_month = round_date(first_date, "month")
  ) -> xdf

# create a nice ndjson file
stream_out(
  x = xdf,
  con = file(output_file),
  verbose = FALSE
)

writeLines(
  text = latest_url,
  con = latest_file
)
