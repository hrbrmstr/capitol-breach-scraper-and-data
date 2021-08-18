library(stringi)
library(rvest)
library(lubridate)
library(tidyverse)

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
  lubridate::parse_date_time(
    ifelse(is.na(d1), d2, d1),
    orders = c("mdY", "mdy", "md")
  )
) -> first_date

# fix `0000` dates
lubridate::year(first_date[!is.na(first_date) & lubridate::year(first_date) == 0]) <- 2021
# fix DoJ year data entry issue
lubridate::year(first_date[name == "BLACK, Joshua Matthew"]) <- 2021

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
    first_date_month = lubridate::round_date(first_date, "month")
  )
## # A tibble: 545 x 10
##    case_num  case_link   name    charges case_doc_links state muni  first_date full_status   first_date_month
##    <chr>     <chr>       <chr>   <list>  <list>         <chr> <chr> <date>     <chr>         <date>
##  1 1:21-cr-… https://ww… ADAMS,… <chr [… <named list [… Ohio  Hill… 2021-03-09 "Arrested 3/… 2021-03-01
##  2 1:21-cr-… https://ww… ALVEAR… <chr [… <named list [… Virg… East… 2021-02-11 "Charged via… 2021-02-01
##  3 1:21-cr-… https://ww… ABUAL-… <chr [… <named list [… New … NA    2021-01-19 "Arrested 1/… 2021-02-01
##  4 21-mj-353 https://ww… ADAMS … <chr [… <named list [… Illi… Spri… 2021-04-13 "Adams Jr. w… 2021-04-01
##  5 1:21-cr-… https://ww… ADAMS,… <chr [… <named list [… Texas East… 2021-01-16 "Arrested 1/… 2021-01-01
##  6 1:21-cr-… https://ww… ADAMS,… <chr [… <named list [… Flor… Edge… 2021-03-10 "Arrest date… 2021-03-01
##  7 1:21-cr-… https://ww… ALAM, … <chr [… <named list [… Penn… East… 2021-01-30 "Arrested 1/… 2021-02-01
##  8 1:21-cr-… https://ww… ALBERT… <chr [… <named list [… Mary… NA    2021-01-07 "Arrested on… 2021-01-01
##  9 1:21-cr-… https://ww… ALFORD… <chr [… <named list [… Alab… Birm… 2021-03-29 "Arrested 3/… 2021-04-01
## 10 1:21-cr-… https://ww… ALLAN,… <chr [… <named list [… Cali… Gran… 2021-01-22 "Arrested 1/… 2021-02-01
## # … with 535 more rows
