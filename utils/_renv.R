library(renv)

renv::init()

pkgs <- c('pacman','tidyverse','tidylog')

renv::install(pkgs, prompt=F)

renv::restore()

renv::snapshot()
