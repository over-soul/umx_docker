# FROM rocker/tidyverse
FROM rocker/r-ver:4.0.2

# Install other libraries
RUN R -e "install.packages(c("littler", "devtools", "furr"))"
RUN R -e "devtools::install_github('tbates/umx')"
