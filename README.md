
[![Daily scraper of DoJ Capitol Breach
Cases](https://github.com/hrbrmstr/capitol-breach-scraper-and-data/actions/workflows/scraper.yml/badge.svg)](https://github.com/hrbrmstr/capitol-breach-scraper-and-data/actions/workflows/scraper.yml)

# capitol-breach-scraper-and-data

R code & daily GH action to scrape the DoJ Capitol Breach Cases

# Always read in the latest successful scrape

``` r
readLines("./docs/latest.txt") |> 
  basename() |> 
  sprintf("./docs/%s", x = _) |> 
  file() |> 
  jsonlite::stream_in(verbose = FALSE) |> 
  str(1)
```

    'data.frame':   1092 obs. of  5 variables:
     $ title          : chr  "ABATE, Joshua" "ABUAL-RAGHEB, Rasha N." "Ackerman, Zachary " "ADAMS JR., Thomas B." ...
     $ link           : chr  "https://www.justice.gov/usao-dc/defendants/abate-joshua" "https://www.justice.gov/usao-dc/defendants/abual-ragheb-rasha-n" "https://www.justice.gov/usao-dc/defendants/ackerman-zachary-0" "https://www.justice.gov/usao-dc/defendants/adams-jr-thomas-b" ...
     $ description    :List of 1092
     $ pubDate        : chr  "February 6, 2023" "February 10, 2023" "July 24, 2023" "March 28, 2023" ...
     $ arrest_location: chr  "" "NEW JERSEY, Bellmore" "New Hampshire" "ILLINOIS, Springfield" ...
