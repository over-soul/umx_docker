# FROM rocker/tidyverse
FROM rocker/r-ver:4.0.2

# Install other libraries
RUN R -e "install.packages(c("litteR", "devtools", "furrr"))"
RUN R -e "devtools::install_github('tbates/umx')"
