FROM debian:11

ENV DEBIAN_FRONTEND=noninteractive

# Install system libraries required for python and R installations
RUN apt-get update && apt-get install -y --no-install-recommends build-essential apt-utils ca-certificates zlib1g-dev gfortran locales libxml2-dev libcurl4-openssl-dev libssl-dev libzmq3-dev libreadline6-dev xorg-dev libcairo-dev libpango1.0-dev libbz2-dev liblzma-dev libffi-dev libsqlite3-dev libopenmpi-dev libhdf5-dev libjpeg-dev libblas-dev liblapack-dev libpcre2-dev libgit2-dev libgmp-dev libgsl-dev tcl-dev tk-dev

# Install common linux tools
RUN apt-get update && apt-get install -y --no-install-recommends wget curl htop less nano vim emacs git

# Configure default locale
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen en_US.utf8 \
    && /usr/sbin/update-locale LANG=en_US.UTF-8

# Download and compile python from source
WORKDIR /opt/python
RUN wget https://www.python.org/ftp/python/3.8.12/Python-3.8.12.tgz
RUN tar zxfv Python-3.8.12.tgz && rm Python-3.8.12.tgz

WORKDIR /opt/python/Python-3.8.12
RUN ./configure --enable-optimizations --with-lto --prefix=/opt/python/
RUN make -j 3 && make install

WORKDIR /opt/python
RUN rm -rf /opt/python/Python-3.8.12
RUN ln -s /opt/python/bin/python3 /opt/python/bin/python
RUN ln -s /opt/python/bin/pip3 /opt/python/bin/pip
ENV PATH="/opt/python/bin:${PATH}"

COPY python-packages.txt /opt/python/python-packages.txt
RUN pip install --no-cache-dir -U pip wheel setuptools==57.5 cmake
RUN pip install --no-cache-dir -r /opt/python/python-packages.txt
RUN jupyter contrib nbextension install --system
RUN jupyter nbextension enable --py widgetsnbextension

# Install nodejs for jupyterlab extensions (installs python2 which crashes cellrank installation, so do this after cellrank installation)
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash -
RUN apt-get install -y --no-install-recommends nodejs
RUN jupyter labextension install @aquirdturtle/collapsible_headings @jupyterlab/toc #jupyterlab-execute-time

# Download and compile R from source
WORKDIR /opt/R
RUN wget https://cran.rstudio.com/src/base/R-4/R-4.1.2.tar.gz
RUN tar xvfz R-4.1.2.tar.gz && rm R-4.1.2.tar.gz

WORKDIR /opt/R/R-4.1.2
RUN ./configure --enable-R-shlib --with-cairo --with-libpng --with-tcltk --prefix=/opt/R/
RUN make -j 3 && make install

WORKDIR /opt/R
RUN rm -rf /opt/R/R-4.1.2
ENV PATH="/opt/R/bin:${PATH}"
ENV LD_LIBRARY_PATH="/opt/R/lib/R/lib:${LD_LIBRARY_PATH}"

RUN Rscript -e "update.packages(ask=FALSE, repos='https://mirror.dogado.de/cran/')"
RUN Rscript -e "install.packages(c('devtools', 'gam', 'RColorBrewer', 'BiocManager', 'IRkernel'), repos='https://mirror.dogado.de/cran/')"
RUN Rscript -e "devtools::install_github(c('patzaw/neo2R', 'patzaw/BED'))"
RUN Rscript -e "BiocManager::install(c('scran','MAST','monocle','ComplexHeatmap','limma','slingshot','clusterExperiment','DropletUtils'), version = '3.14')"
RUN Rscript -e 'writeLines(capture.output(sessionInfo()), "../package_versions_r.txt")' --default-packages=scran,RColorBrewer,slingshot,monocle,gam,clusterExperiment,ggplot2,plyr,MAST,DropletUtils,IRkernel

# Install python-R interoperability packages
RUN pip install --no-cache-dir -U rpy2==3.4.2 anndata2ri
RUN pip freeze > ../package_versions_py.txt
RUN Rscript -e 'writeLines(capture.output(sessionInfo()), "../package_versions_r.txt")' --default-packages=scran,RColorBrewer,slingshot,monocle,gam,clusterExperiment,ggplot2,plyr,MAST,DropletUtils,IRkernel
RUN Rscript -e "IRkernel::installspec(user = FALSE)"

############### BOOK ###############
# Python
RUN pip install --no-cache-dir -U jupyter-book scvi-tools session-info bbknn scib
# R
RUN Rscript -e "BiocManager::install(c('edgeR'), version = '3.14')"

# Fabi's section
RUN apt-get install -y --no-install-recommends freebayes parallel
RUN pip install --no-cache-dir -U pegasuspy vireoSNP PyVCF scSplit
RUN Rscript -e "install.packages(c('Seurat'), repos='https://mirror.dogado.de/cran/')"
## htslib
WORKDIR /opt/htslib
RUN wget https://github.com/samtools/htslib/releases/download/1.14/htslib-1.14.tar.bz2
RUN tar jxfv htslib-1.14.tar.bz2 && rm htslib-1.14.tar.bz2
WORKDIR /opt/htslib/htslib-1.14
RUN ./configure --prefix=/opt/htslib/
RUN make -j 3 && make install
WORKDIR /opt/htslib
RUN rm -rf /opt/htslib/htslib-1.14
## cellsnp-lite (requires htslib)
WORKDIR /opt/cellsnp
RUN git clone https://github.com/single-cell-genetics/cellsnp-lite.git
WORKDIR /opt/cellsnp/cellsnp-lite
RUN autoreconf -iv
RUN ./configure --with-htslib=/opt/htslib --prefix=/opt/cellsnp/
RUN make -j 3 && make install
WORKDIR /opt/cellsnp
RUN rm -rf /opt/cellsnp/cellsnp-lite
ENV PATH="/opt/cellsnp/bin:${PATH}"
## popscle (requires htslib)
WORKDIR /opt/popscle
RUN git clone https://github.com/statgen/popscle.git
WORKDIR /opt/popscle/popscle/build
RUN cmake -DHTS_INCLUDE_DIRS=/opt/htslib/include/  -DHTS_LIBRARIES=/opt/htslib/lib/libhts.a --install-prefix=/opt/popscle/ ..
RUN make -j 3 && make install
WORKDIR /opt/popscle
RUN rm -rf /opt/popscle/popscle
ENV PATH="/opt/popscle/bin:${PATH}"
############### BOOK END ###############

# Copy system files for later use with docker
COPY .bashrc_docker /root/.bashrc
COPY .profile_docker /root/.profile

RUN apt-get clean -y && apt-get autoremove -y
