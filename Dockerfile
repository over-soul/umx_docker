# FROM rocker/tidyverse
FROM rocker/r-ver:4.0.2

# Install other libraries
RUN R -e install2.r --error \
	--deps TRUE \
	devtools \
	furrr
RUN R -e "devtools::install_github('tbates/umx')"
