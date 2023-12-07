# install pkg deps
install.packages(
  pkgs = c("rvest", "xml2", "jsonlite", "stringi"),
  dependencies = c("Depends", "Imports", "LinkingTo")
)

# go about business as usual
library(rvest)
library(stringi)
library(jsonlite, include.only = c("stream_out"))
library(xml2)

today <- as.character(Sys.Date())

output_file <- path.expand(sprintf("docs/%s.json", today))
latest_file <- path.expand("docs/latest.txt")

latest_url <- sprintf("https://hrbrmstr.github.io/capitol-breach-scraper-and-data/%s.json", today)

pg <- read_xml("https://www.justice.gov/rss/defendants/236")

pg |>
  xml_find_all(".//item") -> items

data.frame(
  title = xml_find_all(items, ".//title") |> xml_text(),
  link = xml_find_all(items, ".//link") |> xml_text(),
  description = xml_find_all(items, ".//description") |> html_text() |> lapply(read_html) |> sapply(html_text),
  pubDate = xml_find_all(items, ".//pubDate") |> xml_text()
) -> xdf

xdf$description |>
  stri_split_lines() |>
  lapply(stri_trim_both) |>
  lapply(
    \(.x) .x[nchar(.x) > 0]
  ) -> xdf$description

xdf$description |>
  sapply(\(.x) {
    grep("Location of arrest:", .x, value=TRUE)
  }) |>
  sub("Location of arrest: *", "", x=_) -> xdf$arrest_location

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

