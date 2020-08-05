FROM rocker/tidyverse

# Install other libraries
RUN install2.r --error \
     R -e "library(devtools); \
        install_github('tbates/umx')"