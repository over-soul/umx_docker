FROM ubuntu:18.04

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install gcc g++ gfortran wget cpio && \

  cd /tmp && \
  wget -q http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/15816/l_mkl_2019.5.281.tgz && \
  tar -xzf l_mkl_2019.5.281.tgz && \
  cd l_mkl_2019.5.281 && \
  sed -i 's/ACCEPT_EULA=decline/ACCEPT_EULA=accept/g' silent.cfg && \
  sed -i 's/ARCH_SELECTED=ALL/ARCH_SELECTED=INTEL64/g' silent.cfg && \
  sed -i 's/COMPONENTS=DEFAULTS/COMPONENTS=;intel-comp-l-all-vars__noarch;intel-comp-nomcu-vars__noarch;intel-openmp__x86_64;intel-tbb-libs__x86_64;intel-mkl-common__noarch;intel-mkl-installer-license__noarch;intel-mkl-core__x86_64;intel-mkl-core-rt__x86_64;intel-mkl-doc__noarch;intel-mkl-doc-ps__noarch;intel-mkl-gnu__x86_64;intel-mkl-gnu-rt__x86_64;intel-mkl-common-ps__noarch;intel-mkl-core-ps__x86_64;intel-mkl-common-c__noarch;intel-mkl-core-c__x86_64;intel-mkl-common-c-ps__noarch;intel-mkl-tbb__x86_64;intel-mkl-tbb-rt__x86_64;intel-mkl-gnu-c__x86_64;intel-mkl-common-f__noarch;intel-mkl-core-f__x86_64;intel-mkl-gnu-f-rt__x86_64;intel-mkl-gnu-f__x86_64;intel-mkl-f95-common__noarch;intel-mkl-f__x86_64;intel-mkl-psxe__noarch;intel-psxe-common__noarch;intel-psxe-common-doc__noarch;intel-compxe-pset/g' silent.cfg && \
  ./install.sh -s silent.cfg && \
  cd .. && rm -rf * && \
  rm -rf /opt/intel/.*.log /opt/intel/compilers_and_libraries_2019.3.199/licensing && \
  echo "/opt/intel/mkl/lib/intel64" >> /etc/ld.so.conf.d/intel.conf && \
  ldconfig && \
  echo "source /opt/intel/mkl/bin/mklvars.sh intel64" >> /etc/bash.bashrc
  
# Build R dependencies
RUN sed -Ei 's/^# deb-src /deb-src /' /etc/apt/sources.list && \

  DEBIAN_FRONTEND=noninteractive apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get -y build-dep r-base-dev && \
  DEBIAN_FRONTEND=noninteractive apt-get -y install libcurl4-openssl-dev sysstat libssl-dev  cmake netcdf-bin libnetcdf-dev libxml2-dev ed libssh2-1-dev zip unzip libicu-dev libmariadb-client-lgpl-dev && \
  DEBIAN_FRONTEND=noninteractive apt-get -y remove libblas3 libblas-dev && \
# Instead of relying on Ubuntu Trusty's libpcre 8.31 (which is deemed obsolete by R),
# Try to install 8.43 manually
  sed -e "s/false/true/g" /etc/default/sysstat > /etc/default/sysstat.bak && \
  mv /etc/default/sysstat.bak /etc/default/sysstat && \
  /etc/init.d/sysstat start && \
  cd /home && wget -q https://ftp.pcre.org/pub/pcre/pcre-8.43.tar.gz && \
  tar -zxf pcre-8.43.tar.gz && cd pcre-8.43 && \
  ./configure --enable-pcre16 --enable-pcre32 --enable-jit --enable-utf --enable-pcregrep-libz --enable-pcregrep-libbz2 --enable-pcretest-libreadline && \
  make && make install && cd /home && rm -rf /home/pcre* && \
  ln -sf /opt/intel/lib/intel64/libiomp*.so /usr/lib && cd /home && \
  wget --no-check-certificate -q https://cran.r-project.org/src/base/R-4/R-4.0.2.tar.gz && \
  tar -zxf R-4.0.2.tar.gz && \
  cd /home/R-4.0.2 && \
  export MKLROOT="/opt/intel/compilers_and_libraries_2019.5.281/linux" && \
  export LD_LIBRARY_PATH="${MKLROOT}/tbb/lib/intel64_lin/gcc4.7:${MKLROOT}/compiler/lib/intel64_lin:${MKLROOT}/mkl/lib/intel64_lin" && \
  export LIBRARY_PATH="$LD_LIBRARY_PATH" && \
  export MIC_LD_LIBRARY_PATH="${MKLROOT}/tbb/lib/intel64_lin_mic:${MKLROOT}/compiler/lib/intel64_lin_mic:${MKLROOT}/mkl/lib/intel64_lin_mic" && \
  export MIC_LIBRARY_PATH="$MIC_LD_LIBRARY_PATH" && \
  export CPATH="${MKLROOT}/mkl/include" && \
  export NLSPATH="${MKLROOT}/mkl/lib/intel64_lin/locale/%l_%t/%N" && \
  export MKL="-L${MKLROOT}/mkl/lib/intel64 -Wl,--no-as-needed -lmkl_gf_lp64 -lmkl_intel_thread -lmkl_core -liomp5 -lpthread -lm -ldl" && \
  ./configure CFLAGS="-g -O3" CPPFLAGS="-g -O3" FFLAGS="-g -O3" FCFLAGS="-g -O3 -m64 -I${MKLROOT}/mkl/include" --prefix=/opt/R --enable-R-shlib --enable-shared --enable-R-profiling --enable-memory-profiling --with-blas="$MKL" --with-lapack --with-pcre1 && \
  make && make install && cd /home && rm -Rf /home/R-* && \
  ln -s /opt/R/bin/R /usr/bin/R && \
  ln -s /opt/R/bin/Rscript /usr/bin/Rscript

RUN cd /home && \

  cd /home && \
  wget -q https://github.com/stevengj/nlopt/archive/v2.6.2.tar.gz && ls && \
  tar -zxf v2.6.2.tar.gz && ls && \
  cd nlopt-2.6.2 && \
  cmake -DCMAKE_CXX_FLAGS="-g -O3 -fPIC" && make && make install && \
  cd /home && rm -rf nlopt-* && \

  cd /home && \
  echo "devtools,Rcpp,RcppEigen,R.utils,Matrix,zip,data.table,filematrix,dplyr,reshape2,ggplot2,MASS,car,Hmisc,furrr,benchmarkme" | tr ',' '\n' > /home/pkgs.txt && \
  echo "pkgs <- read.csv('/home/pkgs.txt', header=FALSE, as.is=TRUE)[,1];" > instpkgs.R && \
  echo "print(pkgs);" >> instpkgs.R && \
  echo "install.packages(pkgs, repos='https://cloud.r-project.org/', clean=TRUE, INSTALL_opts='--no-docs --no-demo --byte-compile');" >> instpkgs.R && \
  echo "cat('\n\n\n\n\n\nsessionInfo:\n');" >> instpkgs.R && \
  echo "print(sessionInfo());" >> instpkgs.R && \
  echo "cat('\n\n\n\n\n\nInstalled packages:\n');" >> instpkgs.R && \
  echo "tbl <- installed.packages()[,3, drop=FALSE];" >> instpkgs.R && \
  echo "print(tbl);" >> instpkgs.R && \
  echo "b <- !(pkgs %in% rownames(tbl));" >> instpkgs.R && \
  echo "if (sum(b) > 0) {" >> instpkgs.R && \
  echo "    cat('\n\n\n\n\n\nThe following packages were not installed:\n');" >> instpkgs.R && \
  echo "    print(pkgs[b]);" >> instpkgs.R && \
  echo "} else {" >> instpkgs.R && \
  echo "    cat('\n\n\n\n\n\nAll intended packages were installed!\n');" >> instpkgs.R && \
  echo "}" >> instpkgs.R && \
  echo "devtools::install_github('tbates/umx');" >> instpkgs.R && \
  Rscript --vanilla /home/instpkgs.R && \
rm -Rf /home/*