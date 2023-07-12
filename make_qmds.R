# Read exif data from images, and create qmds for each file

library(exifr)
library(knitr)
library(glue)
library(tidyverse)

lsfiles <- file.info(dir("images", full.names = TRUE,recursive = TRUE))
lsfiles <- lsfiles[order(lsfiles$mtime, decreasing=TRUE),]

files <- rownames(lsfiles)

dat <- read_exif(files)

for(i in 1:length(files)){

  title <- stringr::str_to_title(dat[i,]$ObjectName)
  image_location <- dat[i,]$SourceFile
  date <- dat[i,]$CreateDate %>%
    lubridate::as_datetime()
  description <- dat[i,]$ImageDescription

  file_name <- paste0(gsub(" ","_",title),".qmd")
  directory <- gsub("images/","",dat[i,]$Directory)

  output_dir <- paste0("things/",directory)
  if (!dir.exists(output_dir)) {dir.create(output_dir)}

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

  ",.open = "<<", .close = ">>") %>%
    write_lines(paste0("things/",directory,"/",file_name))

  }

