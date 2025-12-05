FROM ubuntu:24.04

LABEL description="Docker image containing an installation of the ricopili tools version: 2025_Jan_30.003"
LABEL org.opencontainers.image.source=https://github.com/MaastrichtU-Library/rcs-docker-ricopili

# For the tzdata package
RUN ln -fs /usr/share/zoneinfo/Europe/Berlin /etc/localtime


RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates \
             r-base make tk-dev gcc gfortran texlive texlive-fonts-extra \
	     libreadline-dev xorg-dev libxml2-dev libcurl4-gnutls-dev  libgfortran5 \
	     && apt-get clean

RUN useradd -d /ricopili -U -m -s /bin/bash ricopili

RUN mkdir -p  /ricopili/bin \
              /ricopili/dependencies \
              /ricopili/dependencies/R_packages \
              /ricopili/log \
	      /ricopili/reference \
	      /scratch /refs /cluster /work /tsd /projects /net

RUN curl -Lo /tmp/rp_bin.tgz "https://drive.google.com/uc?export=download&id=1UpqMTWadtDpVQwiAGplB4kBq-8XESwBl" && \
      tar zxvf /tmp/rp_bin.tgz --strip 1 -C /ricopili/bin/ && \
      chmod 755 -R /ricopili/bin/ && \
      rm /tmp/rp_bin.tgz

RUN curl -Lo /tmp/rp_dep.tgz "https://personal.broadinstitute.org/braun/sharing/ricopili_dependencies_0225b.tar.gz" && \
    tar zxvf /tmp/rp_dep.tgz -C /ricopili/dependencies/ && \
    chmod 755 -R /ricopili/dependencies/ && \
    rm /tmp/rp_dep.tgz 

RUN Rscript -e 'install.packages("rmeta", repos="https://cloud.r-project.org", lib="/ricopili/dependencies/R_packages")' #&& 

RUN curl -o /tmp/Miniconda2-latest-Linux-x86_64.sh https://repo.anaconda.com/miniconda/Miniconda2-latest-Linux-x86_64.sh && \
    sh /tmp/Miniconda2-latest-Linux-x86_64.sh -b -f -p /usr/local/ && \
    rm /tmp/Miniconda2-latest-Linux-x86_64.sh && \
    cd /ricopili/dependencies/ldsc/ && \
    conda env create --file environment.yml

# Populate log files
RUN touch /ricopili/log/preimp_dir_info \
          /ricopili/log/impute_dir_info \
	  	  /ricopili/log/pcaer_info \
	      /ricopili/log/idtager_info \
	      /ricopili/log/repqc2_info \
	      /ricopili/log/areator_info \
	      /ricopili/log/merge_caller_info \
	      /ricopili/log/postimp_navi_info \
	      /ricopili/log/reference_dir_info \
	      /ricopili/log/test_info \
	      /ricopili/log/clumper_info

# We cannot send emails from docker, so make a fake 
RUN touch /bin/mail && chmod 755 /bin/mail

# To build wo/ caching from now on: docker build -t your-image --build-arg CACHEBUST=$(date +%s)
ARG CACHEBUST=1
RUN rm -f /ricopili/ricopili.conf && \
    curl -o  /ricopili/ricopili.conf https://raw.githubusercontent.com/bruggerk/ricopili_docker/master/ricopili.conf

ENV PATH=/ricopili/bin:/ricopili/bin/pdfjam:$PATH
ENV rp_perlpackages=/ricopili/dependencies/perl_modules/
ENV RPHOME=/ricopili/
