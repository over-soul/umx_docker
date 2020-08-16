FROM rocker/rstudio

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y gnupg2

RUN cd /tmp && \
wget -q https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS-2019.PUB && \
apt-key add GPG-PUB-KEY-INTEL-SW-PRODUCTS-2019.PUB && \
sh -c 'echo deb https://apt.repos.intel.com/mkl all main > /etc/apt/sources.list.d/intel-mkl.list' && \
apt-get update && \
DEBIAN_FRONTEND=noninteractive apt-get -y install intel-mkl-64bit-2020.2-108 && \
update-alternatives --install /usr/lib/x86_64-linux-gnu/libopenblas.so libopenblas.so-x86_64-linux-gnu  /opt/intel/mkl/lib/intel64/libmkl_rt.so 150 && \
update-alternatives --install /usr/lib/x86_64-linux-gnu/libopenblas.so.0 libopenblas.so.0-x86_64-linux-gnu  /opt/intel/mkl/lib/intel64/libmkl_rt.so 150 && \
echo "/opt/intel/lib/intel64"     >  /etc/ld.so.conf.d/mkl.conf && \
echo "/opt/intel/mkl/lib/intel64" >> /etc/ld.so.conf.d/mkl.conf && \
ldconfig && \
echo "MKL_THREADING_LAYER=GNU" >> /etc/environment

# Install other libraries
RUN R -e "install.packages(c('devtools', 'furrr', 'benchmarkme'))"
RUN R -e "devtools::install_github('tbates/umx')"