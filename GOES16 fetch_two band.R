## Script for Fetching GOES-16 Geocolor full disk images

library(curl)
library(rio)
library(stringr)
library(magick)
library(RCurl)

## Import Required images
black_rectangle <- image_read("C://Users//canti021//Documents//black_rectangle.png")
white_rectangle <- image_read("C://Users//canti021//Documents//white_rectangle.png")
black_stripe <- image_read("C://Users//canti021//Documents//black_stripe.png")

## Check for valid internet
if (url.exists("www.google.com")==TRUE) {
  out <- TRUE
} else {
  out <- FALSE
}

if(out==FALSE){
  quit()
}

## Retrieve list of timestamps (for geocolor)
stamps<-import("http://rammb-slider.cira.colostate.edu/data/json/goes-16/full_disk/geocolor/latest_times.json")
time_code <- as.character(stamps$timestamps_int[1])

## Init vectors
a <- vector(mode = "list", length = 8)
b <- vector(mode = "list", length = 8)
c <- vector(mode = "list", length = 8)
d <- vector(mode = "list", length = 8)
e <- vector(mode = "list", length = 8)
f <- vector(mode = "list", length = 8)
g <- vector(mode = "list", length = 8)
h <- vector(mode = "list", length = 8)

image_list <- list(a,b,c,d,e,f,g,h)


## Destination file
destfile <- "C://Users//canti021//Documents//GOES16//total.png"
destfile2 <- "C://Users//canti021//Documents//GOES16//total2.png"

## URL includes most recent timestamped image data (credit to Paul Schuster for assistance)
clump1 <- substr(time_code, 1,8)
clump2<- time_code



## Image tile fetch 2x2 - Geocolor

base_url <- paste("http://rammb-slider.cira.colostate.edu/data/imagery/",clump1,"/goes-16---full_disk/geocolor/",clump2,"/01/",sep="")

a <- vector(mode = "list", length = 8)
b <- vector(mode = "list", length = 8)
c <- vector(mode = "list", length = 8)
d <- vector(mode = "list", length = 8)
e <- vector(mode = "list", length = 8)
f <- vector(mode = "list", length = 8)
g <- vector(mode = "list", length = 8)
h <- vector(mode = "list", length = 8)

image_list <- list(a,b,c,d,e,f,g,h)

for(i in 0:1){
  for(j in 0:1){
    image_list[[i+1]][[j+1]] <- image_read(paste(base_url, "00",i,"_","00",j,".png",sep=""))
  }
}

row1 <- c()
rows <- c()

for(l in 1:2){
  row1 <- c()
  for(k in 1:2){
    row1 <- append(row1, image_list[[l]][[k]], after = length(row1))
  }
  row1 <- image_append(row1)
  rows <- append(rows, row1, after = length(rows))
}
full_image_geocolor <- image_append(rows, stack=TRUE)


## Image tile fetch 2x2 - IR band 11

base_url <- paste("http://rammb-slider.cira.colostate.edu/data/imagery/",clump1,"/goes-16---full_disk/band_11/",clump2,"/01/",sep="")

a <- vector(mode = "list", length = 8)
b <- vector(mode = "list", length = 8)
c <- vector(mode = "list", length = 8)
d <- vector(mode = "list", length = 8)
e <- vector(mode = "list", length = 8)
f <- vector(mode = "list", length = 8)
g <- vector(mode = "list", length = 8)
h <- vector(mode = "list", length = 8)

image_list <- list(a,b,c,d,e,f,g,h)

for(i in 0:1){
  for(j in 0:1){
    image_list[[i+1]][[j+1]] <- image_read(paste(base_url, "00",i,"_","00",j,".png",sep=""))
  }
}

row1 <- c()
rows <- c()

for(l in 1:2){
  row1 <- c()
  for(k in 1:2){
    row1 <- append(row1, image_list[[l]][[k]], after = length(row1))
  }
  row1 <- image_append(row1)
  rows <- append(rows, row1, after = length(rows))
}
full_image_IR <- image_append(rows, stack=TRUE)

adjusted_IR <- append(white_rectangle, full_image_IR, after = length(white_rectangle))
adjusted_IR <- image_append(adjusted_IR, stack =FALSE)
adjusted_IR <- append(adjusted_IR, white_rectangle, after = length(adjusted_IR))
adjusted_IR <- image_append(adjusted_IR, stack =FALSE)

adjusted_geocolor <- append(black_rectangle, full_image_geocolor, after = length(black_rectangle))
adjusted_geocolor <- image_append(adjusted_geocolor, stack =FALSE)
adjusted_geocolor <- append(adjusted_geocolor, black_rectangle, after = length(adjusted_geocolor))
adjusted_geocolor <- image_append(adjusted_geocolor, stack =FALSE)

## Addition of 1 pixel wide black stripe on the left border because of a calculation boo boo
adjusted_geocolor <- append(black_stripe, adjusted_geocolor, after = length(black_stripe))
adjusted_geocolor <- image_append(adjusted_geocolor, stack =FALSE)

total <- append(adjusted_geocolor, adjusted_IR)
total <- image_append(total, stack = FALSE)

total <- image_fill(total, "black", point = "+2800+700", fuzz = 300)

image_write(total, path = destfile, format = "png")
image_write(total, path = destfile2, format = "png")
## Url Format reminder:
## "http://rammb-slider.cira.colostate.edu/data/imagery/20171001/goes-16---full_disk/geocolor/20171001210038/00/000_000.png"
