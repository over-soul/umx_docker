FROM rocker/rstudio

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get -y upgrade && apt-get clean
RUN apt-get install -y gnupg2 nano libxml2-dev libv8-dev librsvg2-2 libcairo2-dev libssh2-1-dev libcurl4-openssl-dev libssl-dev

# Install Intel MKL
RUN sudo apt install intel-mkl

RUN echo "MKL_INTERFACE_LAYER=GNU,LP64" >> /etc/environment && \
echo "MKL_THREADING_LAYER=GNU" >> /etc/environment && \
echo "MKL_INTERFACE_LAYER=GNU,LP64" >> /usr/local/lib/R/etc/Renviron && \
echo "MKL_THREADING_LAYER=GNU" >> /usr/local/lib/R/etc/Renviron && \
echo "auth-timeout-minutes=0" >> /etc/rstudio/rserver.conf

# Install packages
RUN R -e "update.packages(ask = FALSE)" \
R -e "install.packages(c('devtools', 'benchmarkme', 'umx'))"
#RUN R -e "devtools::install_github('tbates/umx')"
