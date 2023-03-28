# ClevelandArt_fun_facts
This is the R code to the tweetbot that produces 365 daily tweets with fun facts taken from the Cleveland Museum of Art's open data. A project by [@HxxxKxxx](https://twitter.com/hxxxkxxx)

Update: I have updated my tweetbot in March 2023! Now, it uses [GPT-4](https://openai.com/product/gpt-4) to compose tweets by directly sourcing from the API. Using the elements "title", "description", and "fun_fact", it generates a tweet and sends it to Twitter along with the URL and the first image. This is not represented in the code here.

## Data
The open data contain a filed "[fun_fact](https://twitter.com/HxxxKxxx/status/1088507121002516480)" to some of the objects as well as URLs to images of the objects. 365 have both a fun_fact and an image. 

Information about the museum's open access can policy be found here: 
http://www.clevelandart.org/open-access

Possible errors found in data: 
-	Some Fun_fact contains “\&quot;” , “\<em>”, “\</em>”, “<U+0085>” 
-	Some of both Tombstone and Title contain “\n” and “\r”
-	Dates BC are a positive number in creation_date_earliest
-	[Rousseau](http://www.clevelandart.org/art/1980.18) has a fun_fact on Pollock


## R Code
With the CSV file imported, this code creates a subset with non-empty fields of "fun_fact", downloads the images, creates flashcards with the image, fun fact, title and date on a background with the images' average color and subsequently a TSV file for upload to autochirp. It makes use of the package [Imager](https://cran.r-project.org/web/packages/imager/index.html). 

## Tweet Bot
For scheduled tweets, [autochirp](https://autochirp.spinfo.uni-koeln.de/home) from the University of Cologne is used.

It requires a TSV with the fields date, time, tweet content, image attachment, latitude, longitude in UTF8. Line breaks are allowed if the escape sequence is [retained](https://twitter.com/spinfocl/status/1093991712844902403).

## Result
The resulting twitter account can be found here: https://twitter.com/CArt_fun_facts
