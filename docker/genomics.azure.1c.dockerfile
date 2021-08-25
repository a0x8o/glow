FROM projectglow/databricksruntime-r:8.x AS r 

# ===== Build off Databricks Runtime ===============================================================

#The runtime base is Ubuntu 18.04, or 20.04 after 9.x
#See more here https://github.com/databricks/containers

# FROM databricksruntime/standard:8.x 

# ===== Set up python environment ==================================================================

RUN /databricks/conda/envs/dcs-minimal/bin/pip install databricks-cli --no-cache-dir

# ===== Set up VEP environment =====================================================================

RUN apt-get update && apt-get install -y \
    apt-utils \
    build-essential \
    git \
    apt-transport-https \
    ca-certificates \
    cpanminus \
    libpng-dev \
    zlib1g-dev \
    libbz2-dev \
    liblzma-dev \
    perl \
    perl-base \
    unzip \
    curl \
    gnupg2 \
    software-properties-common \
    jq \
    libjemalloc1 \
    libjemalloc-dev \
    libdbi-perl \
    libdbd-mysql-perl \
    libdbd-sqlite3-perl \
    zlib1g \
    zlib1g-dev \
    libxml2 \
    libxml2-dev 


# ===== Set up R genomics packages =================================================================

RUN R -e "install.packages('sim1000G',dependencies=TRUE,repos='https://cran.rstudio.com')"\
 && R -e "install.packages('ukbtools',dependencies=TRUE,repos='https://cran.rstudio.com')"

# ===== Set up VEP environment =====================================================================

ENV OPT_SRC /opt/vep/src
ENV PERL5LIB $PERL5LIB:$OPT_SRC/ensembl-vep:$OPT_SRC/ensembl-vep/modules
RUN cpanm DBI && \
    cpanm Set::IntervalTree && \
    cpanm JSON && \
    cpanm Text::CSV && \
    cpanm Module::Build && \
    cpanm PerlIO::gzip && \
    cpanm IO::Uncompress::Gunzip

RUN mkdir -p $OPT_SRC
WORKDIR $OPT_SRC
RUN git clone https://github.com/Ensembl/ensembl-vep.git
WORKDIR ensembl-vep

# The commit is the most recent one on release branch 100 as of July 29, 2020

RUN git checkout 10932fab1e9c113e8e5d317e1f668413390344ac && \
    perl INSTALL.pl --NO_UPDATE -AUTO a && \
    perl INSTALL.pl -n -a p --PLUGINS AncestralAllele && \
    chmod +x vep

# ===== Set up Azure CLI =====

RUN apt-get install -y \
    curl \
    lsb-release \
    gnupg

RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# ===== Set up samtools ============================================================================

RUN apt-get update && apt-get install -y \
    libncurses-dev

WORKDIR /opt
RUN wget https://github.com/samtools/samtools/releases/download/1.9/samtools-1.9.tar.bz2 && \
    tar -xjf samtools-1.9.tar.bz2
WORKDIR samtools-1.9
RUN ./configure && \
    make && \
    make install

# ===== Set up bedtools ============================================================================

RUN wget https://github.com/arq5x/bedtools2/releases/download/v2.30.0/bedtools.static.binary
RUN mv bedtools.static.binary /opt/bedtools
RUN chmod a+x /opt/bedtools

# ===== QQMAN ======================================================================================

ENV QQMAN_VERSION=1.0.6
RUN /databricks/conda/envs/dcs-minimal/bin/pip install qqman==$QQMAN_VERSION

ENV MLFLOW_VERSION=1.19.0
#ENV KOALAS_VERSION=1.8.1
#ENV PANDAS_VERSION=1.3.1
#ENV XGBOOST_VERSION=1.4.2
#ENV HYPEROPT_VERSION=0.2.5
#ENV HOLIDAYS_VERSION=0.11.2

RUN /databricks/conda/envs/dcs-minimal/bin/pip install qqman==$QQMAN_VERSION
RUN /databricks/conda/envs/dcs-minimal/bin/pip install mlflow==$MLFLOW_VERSION
#RUN /databricks/conda/envs/dcs-minimal/bin/pip install koalas==$KOALAS_VERSION
#RUN /databricks/conda/envs/dcs-minimal/bin/pip install pandas==$PANDAS_VERSION
#RUN /databricks/conda/envs/dcs-minimal/bin/pip install xgboost==$XGBOOST_VERSION
#RUN /databricks/conda/envs/dcs-minimal/bin/pip install hyperopt==$HYPEROPT_VERSION
#RUN /databricks/conda/envs/dcs-minimal/bin/pip install holidays==$HOLIDAYS_VERSIO


# ===== Reset current directory ====================================================================

RUN cd /root