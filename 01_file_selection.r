####################################################################
# LFS Thailand revisit
# Part 1 Organize target files
# 
# 19th. February 2026 
# 
# Yuzuru Utsunomiya Ph D.
# (Faculty of Economics, Nagasaki University)
####################################################################
# 
## ---- read.library ----
library(tidyverse)
library(fs)
# 
## ---- copy files ----
# obatin target files
# set target directory
# 2534-2562
src <- "/mnt/d/to_be_saved/labour_force_survey_Thailand/LfsProvince"
# 2563-2565
src <- "/mnt/d/to_be_saved/labour_force_survey_Thailand/lfs_Thailand_2563_2565"
# destination to be copied
dst <- "/mnt/d/to_be_saved/extracted_100"
# make a new directory for copying
dir_create(dst)

# select target files in accordance with following condition
files <- 
  dir_ls(
    src, 
    recurse = TRUE, 
    type = "file"
    ) %>%
  as.character() %>%
  purrr::keep(
    ~ 
      # condition
      # any files including "100.xls" in their file names
      stringr::str_detect(
        .x, 
        regex(
          "100\\.xls$", 
          ignore_case = TRUE
          )
        )
    )
# 
# a helper to copy target file
copy_one <- 
  purrr::possibly(
    function(from, to) { 
      fs::file_copy(from, to, overwrite = FALSE); TRUE 
      },
    otherwise = FALSE
    )
# copy
res <-
  # pass paths of target files
  tibble::tibble(path = files) %>%
  dplyr::mutate(
    # obtain file names
    file_name = fs::path_file(path),
    parent    = fs::path_file(fs::path_dir(path)),
    # provide new names
    new_name  = stringr::str_c(parent, "__", file_name),
    # copy to
    to        = fs::path(dst, new_name),
    # copy target files here
    copied    = purrr::map2_lgl(path, to, copy_one)
  )
# check status
res %>% count(copied)
res %>% filter(!copied) %>% select(path, to) %>% slice_head(n = 20)
