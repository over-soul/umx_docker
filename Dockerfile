FROM rocker/tidyverse

# Install other libraries
RUN R -e "devtools::install_github('tbates/umx')" \
	&& install2.r --error \
	--deps TRUE \
	furrr