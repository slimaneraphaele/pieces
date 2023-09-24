# Read exif data from images, and create qmds for each file

library(exifr)
library(knitr)
library(glue)
library(tidyverse)


# get images in directory
lsfiles <- file.info(dir("playground_images/meeting_mountains", full.names = TRUE,recursive = TRUE))
lsfiles <- lsfiles[order(lsfiles$mtime, decreasing=TRUE),]

files <- rownames(lsfiles)

dat <- read_exif(files)

for(i in 1:length(files)){

  title <- stringr::str_to_title(dat[i,]$FileName)
  title <- unlist(strsplit(title,split = "\\."))[1]
  image_location <- dat[i,]$SourceFile
  date <- dat[i,]$FileModifyDate %>%
    lubridate::as_datetime()
  description <- "Meeting of the mountains processed with stable diffusion"

  file_name <- paste0(gsub(" ","_",title),".qmd")
  directory <- gsub("playground_images/","",dat[i,]$Directory)

  output_dir <- paste0("playground/",directory)
  if (!dir.exists(output_dir)) {dir.create(output_dir)}

  # if file exists don't overwrite
  if (!file.exists(paste0(output_dir,"/",file_name))) {
    glue("
  ---
  title: <<title>>
  author: Matt Crump
  image: ../../<<image_location>>
  description: <<description>>
  categories: [<<directory>>]
  date: <<date>>
  format:
    html:
      page-layout: full
  ---

  ![](../../<<image_location>>)

  ## Process notes

  [Meeting of the mountains](hhttps://www.crumplab.com/things/things/Colorlands/Meeting_Of_The_Mountains.html) processed through stable diffusion v 1.5, and the scribble control net with default scheduler. The line art was inverted as the scribble source.

  ",.open = "<<", .close = ">>") %>%
      write_lines(paste0("playground/",directory,"/",file_name))
     }

  }

