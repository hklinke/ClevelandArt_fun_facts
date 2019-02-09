# Fun Facts from the Cleveland Museum of Art
# A project by Harald Klinke  @HxxxKxxx 
# This bot chronologically tweets fun facts about objects in the Cleveland Museum of Art until today next year.
# Not affiliated with but using open data from @clevelandart
#If you would like to suggest improvements, I would be happy to hear from you! 

# Import data from https://github.com/ClevelandMuseumArt
cleveland_data <- read.csv("~/R/DATA/cleveland-data.csv", encoding="UTF-8", stringsAsFactors=FALSE)

# Create subset
funfactsonly=subset(cleveland_data, !cleveland_data$fun_fact=="")

library(imager)
subfolder="images_web/"
folder_twitter="images_twitter/"

# First a few small changes on the data
funfactsonly$fun_fact=gsub("&quot;","\'",funfactsonly$fun_fact)
funfactsonly$fun_fact=gsub("mÃ¢chÃ©", "maché",funfactsonly$fun_fact)
funfactsonly$fun_fact=gsub("<em>", "'",funfactsonly$fun_fact)
funfactsonly$fun_fact=gsub("</em>", "'",funfactsonly$fun_fact)
funfactsonly$fun_fact=gsub("<U+0085>", "",funfactsonly$fun_fact)
funfactsonly$fun_fact=gsub("VÃ¶ls", "Völs",funfactsonly$fun_fact)
funfactsonly$tombstone=gsub("\n", "",funfactsonly$tombstone)
funfactsonly$tombstone=gsub("\r", "",funfactsonly$tombstone)
funfactsonly$title=gsub("\n", "",funfactsonly$title)
funfactsonly$title=gsub("\r", "",funfactsonly$title)

# Sort data by creation date
funfactsonly=funfactsonly[order(funfactsonly$creation_date_earliest),]

# Initialize the new column 
funfactsonly$image_web_filename=""

# Download all images
for (i in 1:nrow(funfactsonly)) {
  this_url=funfactsonly$image_web[i]
  filename=paste(subfolder,funfactsonly$X.U.FEFF.id[i],".jpg", sep = "")       
  if (this_url!="") {
    download.file(this_url, filenme, mode = "wb", #binary
                  method = "libcurl", 
                  quiet = TRUE) 
    funfactsonly$thumb_OK[i]=TRUE
    funfactsonly$image_web_filename[i]=filename
  }
  else
  {
    funfactsonly$thumb_OK[i]=FALSE
  }
} 

# Create new columns with size, average color and brightness for later use
# Initialize
funfactsonly$mean=0
funfactsonly$av_r=0
funfactsonly$av_g=0
funfactsonly$av_b=0
funfactsonly$thumb_width=0
funfactsonly$thumb_height=0

for (i in 1:nrow(funfactsonly)) {
  if (funfactsonly$thumb_OK[i]==TRUE) {
    this_image=load.image(funfactsonly$image_web_filename[i])
    funfactsonly$mean[i]=mean(grayscale(this_image))  
    funfactsonly$av_r[i]=mean(R(this_image)) #R
    funfactsonly$av_g[i]=mean(G(this_image)) #G
    funfactsonly$av_b[i]=mean(B(this_image)) #B
    funfactsonly$thumb_width[i]=width(this_image) #width
    funfactsonly$thumb_height[i]=height(this_image) #height
  }
}

# Create flashcards for Twitter
for (i in 1:nrow(funfactsonly)) {
  background_col=c(funfactsonly$av_r[i],funfactsonly$av_g[i],funfactsonly$av_b[i])
  if (funfactsonly$thumb_OK[i]==TRUE) {
    this_image=load.image(funfactsonly$image_web_filename[i])
    half_height=1263/2
    if (funfactsonly$thumb_width[i]>funfactsonly$thumb_height[i]) { 
      if (1263/width(this_image)*height(this_image)>half_height) {
        #stretch to half height 
        this_image=imresize(this_image, half_height/height(this_image))
      } else {
        #stretch to full width
        this_image=imresize(this_image, 1263/width(this_image))
      }
      this_image=pad(this_image,
               axes="y",half_height-height(this_image), pos=0, 
               val=background_col )
      #add space if necessary 
      this_image=pad(this_image,
               axes="x",1263-width(this_image), pos=0, 
               val=background_col )
      } else {  
        this_image=imresize(bild, (1263/2)/height(this_image))
        this_image=pad(pad(this_image,
                     axes="x",1263-width(this_image), pos=0, 
                     val=c(funfactsonly$av_r[i],funfactsonly$av_g[i],funfactsonly$av_b[i])),
                 axes="y",1263-height(this_image), pos=1, 
                 val=background_col )
      }
    #Add lower half
    this_image=pad(this_image,
             axes="y",1263-height(this_image), pos=1, 
             val=c(funfactsonly$av_r[i],funfactsonly$av_g[i],funfactsonly$av_b[i]))
    #Add text
    caption_margin=50
    #Font color depending on brightness
    if (funfactsonly$mean[i]>=.5) {
      text_color="black"
      meta_color=rgb(0,0,0,alpha=.5)
    } else {
    text_color="white"
    meta_color=rgb(1,1,1,alpha=.5)
    }
    this_image=implot(this_image, text(1263/2,1263/4*3, 
                                       paste(
                                         paste(
                                           strwrap(funfactsonly$fun_fact[i], width = 55, indent = 0,
                                                   exdent = 0, prefix = "", simplify = TRUE, initial = "")
                                           ,"\n" )
                                         ,collapse="")
                                       , cex=3, col = text_color) ) 
    # Create caption
    ellipsis="..." 
    title=funfactsonly$title[i]
    date=funfactsonly$creation_date[i]
    if (nchar(date)>20) {
      date=paste(substring(date,0,18),ellipsis,sep="")
    }
    creator=funfactsonly$creators[i]
    if (nchar(creator)>60) {
      creator=paste(substring(creator,0,55),ellipsis,sep="")
    }
    caption=paste(title, date, sep=", ")
    if (nchar(caption)>65) {
      caption=paste(
        paste(substr(title,0,60),ellipsis,sep=""), 
        date, sep=", ")
    }
    if (!creator=="") {
        caption=paste(creator,"\n",caption,sep="")   
    } 
    this_image=implot(this_image, text(1263/2,1263-caption_margin, 
                           caption
                           , cex=2, col = meta_color) ) 
    save.image(this_image, paste(folder_twitter, funfactsonly$X.U.FEFF.id[i], ".jpg", sep = ""))
  } 
}
# Now upload the images to a folder in the web

# Create tweets
tweet_imgurl="http://yourdomain/ClevelandArt_fun_facts/" #This is the folder in the web
tweet_line_break="\\n" #Retain line break
remove(tweet_tsv) #If you repeat this, make sure it is empty
tweet_tsv=setNames(data.frame(matrix(ncol = 6, nrow = 0)), 
                   c("Date", "Time", "Tweet", "Picture", "Longitude", "Lattitude"))
tweet_date=as.Date("2019-02-10")
tweet_time="07:30"

#First line
tweet_text=paste("This bot chronologically tweets fun facts about objects at the Cleveland Museum of Art until today next year.",
                 tweet_line_break,
                 "Not affiliated with but using open data from @clevelandart",
                 tweet_line_break,
                 "A project by @HxxxKxxx",
                 tweet_line_break, 
                 "#DigitalArtHistory @auto_chirp", sep="")
image_url=paste(tweet_imgurl, "banner.jpg", sep="")
tweet_tsv[1,] = list(as.character(tweet_date),"07:20",tweet_text, image_url, "", "")

#Following lines
for (i in 1:nrow(funfactsonly)) {
  if (funfactsonly$thumb_OK[i]==TRUE) {
    tweet_text=paste(substring(funfactsonly$tombstone[i],1, 90),ellipsis, sep = "")
    if (!funfactsonly$type[i]=="") {
      tweet_hash1=paste("#",gsub( " .*$", "", funfactsonly$type[i]), sep = "")
    } else{
      tweet_hash1="#DigitalArtHistory"
      }
    if (!funfactsonly$technique[i]=="") {
      tweet_hash2=gsub( "[ ,;-].*$", "", funfactsonly$technique[i]) 
      tweet_hash2=paste(toupper(substr(tweet_hash2, 1, 1)), substr(tweet_hash2, 2, nchar(tweet_hash2)), sep="")
      tweet_hash2=paste("#",tweet_hash2, sep = "") 
      if (tweet_hash2=="#Possibly") {
        tweet_hash2="#" #Your alternative hashtag
      }
      if (tweet_hash2==tweet_hash1) {
        tweet_hash2="#"
      } 
    } else{
      tweet_hash2="#"
    }
    tweet_credit=" at @clevelandart"
    tweet_url=funfactsonly$url[i]
    tweet_text=paste(tweet_text,  tweet_credit, tweet_line_break, tweet_hash1, " ", tweet_hash2, tweet_line_break, tweet_url, sep = "")
    image_url=paste(tweet_imgurl, funfactsonly$X.U.FEFF.id[i], ".jpg", sep="")
    tweet_tsv[nrow(tweet_tsv) + 1,] = list(as.character(tweet_date),tweet_time,tweet_text, image_url, "", "")

    tweet_date=tweet_date+1 #Increment the day
    }
}

#Last line
tweet_text=paste("That's it. The fun facts are over. Thank you @clevelandart",
                 tweet_line_break,
                 "This has been a project by @HxxxKxxx",
                 tweet_line_break,
                 "#DigitalArtHistory #TwitterOff", sep="")
image_url=paste(tweet_imgurl, "banner.jpg", sep="")
tweet_tsv[nrow(tweet_tsv) + 1,] = list(as.character(tweet_date-1),"07:31",tweet_text, image_url, "", "")

#Write Tweets in TSV
write.table(tweet_tsv, file="tweets.tsv", sep="\t",quote=FALSE, 
            row.names = FALSE, col.names = TRUE, fileEncoding = "UTF-8")

#Now upload the file to autochirp and happy tweeting...
