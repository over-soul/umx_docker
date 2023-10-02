FROM rocker/rstudio

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get -y upgrade && apt-get clean
RUN apt-get install -y gnupg2 nano libxml2-dev libv8-dev librsvg2-2 libcairo2-dev libssh2-1-dev libcurl4-openssl-dev libssl-dev

# Install Intel MKL
RUN cd /tmp && \
wget -q https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS-2019.PUB && \
apt-key add GPG-PUB-KEY-INTEL-SW-PRODUCTS-2019.PUB && \
sh -c 'echo deb https://apt.repos.intel.com/mkl all main > /etc/apt/sources.list.d/intel-mkl.list' && \
apt-get update && \
apt-get -y install intel-mkl-64bit-2020.2-108 && \
update-alternatives --install /usr/lib/x86_64-linux-gnu/libopenblas.so libopenblas.so-x86_64-linux-gnu  /opt/intel/mkl/lib/intel64/libmkl_rt.so 150 && \
update-alternatives --install /usr/lib/x86_64-linux-gnu/libopenblas.so.0 libopenblas.so.0-x86_64-linux-gnu  /opt/intel/mkl/lib/intel64/libmkl_rt.so 150 && \
echo "/opt/intel/lib/intel64"     >>  /etc/ld.so.conf.d/mkl.conf && \
echo "/opt/intel/mkl/lib/intel64" >> /etc/ld.so.conf.d/mkl.conf && \
ldconfig

RUN echo "MKL_INTERFACE_LAYER=GNU,LP64" >> /etc/environment && \
echo "MKL_THREADING_LAYER=GNU" >> /etc/environment && \
echo "MKL_INTERFACE_LAYER=GNU,LP64" >> /usr/local/lib/R/etc/Renviron && \
echo "MKL_THREADING_LAYER=GNU" >> /usr/local/lib/R/etc/Renviron && \
echo "auth-timeout-minutes=0" >> /etc/rstudio/rserver.conf

# Install packages
RUN R -e "update.packages(ask = FALSE)" \
R -e "install.packages(c('devtools', 'benchmarkme', 'umx'))"
#RUN R -e "devtools::install_github('tbates/umx')"
