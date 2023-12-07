
[![Daily scraper of DoJ Capitol Breach
Cases](https://github.com/hrbrmstr/capitol-breach-scraper-and-data/actions/workflows/scraper.yml/badge.svg)](https://github.com/hrbrmstr/capitol-breach-scraper-and-data/actions/workflows/scraper.yml)

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

    Rows: 1,092
    Columns: 4
    $ title       <chr> "ABATE, Joshua", "ABUAL-RAGHEB, Rasha N.", "Ackerman, Zach…
    $ link        <chr> "https://www.justice.gov/usao-dc/defendants/abate-joshua",…
    $ description <chr> "Case number: 1:23-mj-14\nName: ABATE, Joshua\nCharges: Se…
    $ pubDate     <chr> "February 6, 2023", "February 10, 2023", "July 24, 2023", …
