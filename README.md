[![Daily scraper of DoJ Capitol Breach Cases](https://github.com/hrbrmstr/capitol-breach-scraper-and-data/actions/workflows/scraper.yml/badge.svg)](https://github.com/hrbrmstr/capitol-breach-scraper-and-data/actions/workflows/scraper.yml)

# capitol-breach-scraper-and-data 

R code & daily GH action to scrape the DoJ Capitol Breach Cases

# Always read in the latest successful scrape

```r
jsonlite::stream_in(
  url(
    readLines(
      "https://hrbrmstr.github.io/capitol-breach-scraper-and-data/latest.txt"
    )
  ),
  verbose = FALSE
) |>
  dplyr::glimpse()
## Rows: 547
## Columns: 10
## $ case_num         <chr> "1:21-cr-212", "1:21-cr-115", "1:21-cr-43", "21-mj-353", "1:2…
## $ case_link        <chr> "https://www.justice.gov/usao-dc/defendants/adams-jared-hunte…
## $ name             <chr> "ADAMS, Jared Hunter", "ALVEAR GONZALEZ, Eduardo Nicolas (aka…
## $ charges          <list> <"Entering and Remaining in a Restricted Building", "Disorde…
## $ case_doc_links   <df[,1112]> <data.frame[29 x 1112]>
## $ state            <chr> "Ohio", "Virginia", "New Jersey", "Illinois", "Texas", …
## $ muni             <chr> "Hilliard", "Eastern District", NA, "Springfield", "Eastern D…
## $ first_date       <chr> "2021-03-09", "2021-02-11", "2021-01-19", "2021-04-13", "2021…
## $ full_status      <chr> "Arrested 3/9/2021. Charged via criminal information on 3/11/…
## $ first_date_month <chr> "2021-03-01", "2021-02-01", "2021-02-01", "2021-04-01", "2021…
## 
```
