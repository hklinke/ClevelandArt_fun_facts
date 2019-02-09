# ClevelandArt_fun_facts
This is the R code that produces 365 daily tweets with fun facts taken from the Cleveland Museum of Art's open data.

## Data
Information about the museum's open access can policy be found here: 
http://www.clevelandart.org/open-access

Possible errors found in data: 
-	Fun_fact contains “\&quot;” , “\<em>”, “\</em>”, “<U+0085>” 
-	Both Tombstone and title contain “\n” and “\r”
-	Dates BC are a positive number in creation_date_earliest
-	[Rousseau](http://www.clevelandart.org/art/1980.18) has a fun_fact on Pollock


## R Code
With the CSV file imported, this code creates a subset with non-empty fields of "fun_fact", downloads the images, creates flashcards with the image, fun fact, title and date on a background with the images's average color and subsequently a TSV file for upload to autochirp. 

## Tweet Bot
For scheduled tweets, autochirp from the University of Cologne is used: 
https://autochirp.spinfo.uni-koeln.de/home

It requires a TSV with the fields date, time, tweet content, image attachment, latitude, longitude in UTF8. Line breaksare allowed if the escape sequence is [retained](https://twitter.com/spinfocl/status/1093991712844902403).

## Result
The resulting twitter account can be found here: https://twitter.com/CArt_fun_facts
