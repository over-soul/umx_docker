FROM rocker/r-base

# Install other libraries
RUN install2.r --error \
        devtools \
    && R -e "library(devtools); \
        install_github('tbates/umx')"