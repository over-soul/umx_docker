FROM rocker/rstudio

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get -y upgrade && apt-get clean
RUN apt-get install -y gnupg2 nano libxml2-dev libv8-dev librsvg2-2 libcairo2-dev libssh2-1-dev libcurl4-openssl-dev libssl-dev

# Install Intel MKL
RUN sudo apt install intel-mkl && \
update-alternatives --install /usr/lib/x86_64-linux-gnu/libblas.so \
                    libblas.so-x86_64-linux-gnu      /opt/intel/mkl/lib/intel64/libmkl_rt.so 50
update-alternatives --install /usr/lib/x86_64-linux-gnu/libblas.so.3 \
                    libblas.so.3-x86_64-linux-gnu    /opt/intel/mkl/lib/intel64/libmkl_rt.so 50
update-alternatives --install /usr/lib/x86_64-linux-gnu/liblapack.so \
                    liblapack.so-x86_64-linux-gnu    /opt/intel/mkl/lib/intel64/libmkl_rt.so 50
update-alternatives --install /usr/lib/x86_64-linux-gnu/liblapack.so.3 \
                    liblapack.so.3-x86_64-linux-gnu  /opt/intel/mkl/lib/intel64/libmkl_rt.so 50
                    
# Next, we have to tell the dyanmic linker about two directories use by the MKL, and have it update its cache:
RUN echo "/opt/intel/lib/intel64"     >  /etc/ld.so.conf.d/mkl.conf && \
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
