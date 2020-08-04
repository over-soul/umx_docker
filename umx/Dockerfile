FROM rocker/r-base
RUN mkdir /home/analysis

RUN R -e "install.packages('devtools')"
RUN R -e "devtools::install_github("tbates/umx")"