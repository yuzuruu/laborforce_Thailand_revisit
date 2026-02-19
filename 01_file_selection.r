

library(tidyverse)
library(fs)

src <- "/mnt/d/to_be_saved/labour_force_survey_Thailand/LfsProvince"
src <- "/mnt/d/to_be_saved/labour_force_survey_Thailand/lfs_Thailand_2563_2565"

dst <- "/mnt/d/to_be_saved/extracted_100"

dir_create(dst)

# 再帰的に全ファイルを列挙 → 条件で絞る
files <- 
  dir_ls(
    src, 
    recurse = TRUE, 
    type = "file"
    ) %>%
  as.character() %>%
  purrr::keep(
    ~ 
      stringr::str_detect(
        .x, 
        regex(
          "100\\.xls$", 
          ignore_case = TRUE
          )
        )
    )


copy_one <- 
  purrr::possibly(
    function(from, to) { 
      fs::file_copy(from, to, overwrite = FALSE); TRUE 
      },
    otherwise = FALSE
    )

res <- 
  tibble::tibble(path = files) %>%
  dplyr::mutate(
    file_name = fs::path_file(path),
    parent    = fs::path_file(fs::path_dir(path)),
    new_name  = stringr::str_c(parent, "__", file_name),
    to        = fs::path(dst, new_name),
    # copy target files here
    copied    = purrr::map2_lgl(path, to, copy_one)
  )


res %>% count(copied)
res %>% filter(!copied) %>% select(path, to) %>% slice_head(n = 20)
