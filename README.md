# ClevelandArt_fun_facts
This is the R code that produces tweets with fun facts taken from the Cleveland Museum of Art's open data.

## Data
Information about open access can be found here: 

http://www.clevelandart.org/open-access

## R Code
With the CSV file imported, this code creates a subset with non-empty fields od "fun_fact", downloads the images, creates flashcards with the image, fun fact, title and date on a background with the images's average color and creates a TSV file for upload. 

## Tweet Bot
For scheduled tweets, autochirp from the University of Cologne is used

https://autochirp.spinfo.uni-koeln.de/home

It requires a TSV with certain fields, no line breaks, UTF8.
