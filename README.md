
<div>

[![](https://github.com/hrbrmstr/capitol-breach-scraper-and-data/actions/workflows/scraper.yml/badge.svg)](https://github.com/hrbrmstr/capitol-breach-scraper-and-data/actions/workflows/scraper.yml)

Daily scraper of DoJ Capitol Breach Cases

</div>

# capitol-breach-scraper-and-data

R code & daily GH action to scrape the DoJ Capitol Breach Cases

# Always read in the latest successful scrape

``` r
jsonlite::stream_in(
  url(
    readLines(
      "https://hrbrmstr.github.io/capitol-breach-scraper-and-data/latest.txt"
    )
  ),
  verbose = FALSE
) |>
  dplyr::glimpse()
```

    Rows: 956
    Columns: 10
    $ case_num         <chr> "1:21-cr-212", "1:21-cr-115", "1:23-mj-14", "1:21-cr-…
    $ case_link        <chr> "https://www.justice.gov/usao-dc/defendants/adams-jar…
    $ name             <chr> "ADAMS, Jared Hunter", "ALVEAR GONZALEZ, Eduardo Nico…
    $ charges          <list> "See accompanying documents.", "See accompanying doc…
    $ case_doc_links   <df[,2879]> <data.frame[26 x 2879]>
    $ state            <chr> "Ohio", "Virginia", "", "New Jersey", "Illinois…
    $ muni             <chr> "Hilliard", "Eastern District", NA, "Bellmore", "Spri…
    $ first_date       <chr> "2021-03-09", "2021-02-11", NA, "2021-01-19", "2021-0…
    $ full_status      <chr> "Arrested 3/9/2021. Charged via criminal information …
    $ first_date_month <chr> "2021-03-01", "2021-02-01", NA, "2021-02-01", "2021-0…
