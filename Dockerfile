FROM ubuntu:bionic

USER root
COPY . ${HOME}

LABEL org.label-schema.license="GPL-2.0" \
      org.label-schema.vcs-url="https://github.com/rocker-org/r-apt" \
      org.label-schema.vendor="Rocker Project" \
      maintainer="Dirk Eddelbuettel <edd@debian.org>"

## Set a default user. Available via runtime flag `--user docker`
## Add user to 'staff' group, granting them write privileges to /usr/local/lib/R/site.library
## User should also have & own a home directory (for rstudio or linked volumes to work properly).
RUN useradd docker \
	&& mkdir /home/docker \
	&& chown docker:docker /home/docker \
	&& addgroup docker staff

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		software-properties-common \
                ed \
		less \
		locales \
		vim-tiny \
		wget \
    sudo \
		ca-certificates \
        && add-apt-repository --enable-source --yes "ppa:marutter/rrutter3.5" \
	&& add-apt-repository --enable-source --yes "ppa:marutter/c2d4u3.5"

## Configure default locale, see https://github.com/rocker-org/rocker/issues/19
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
	&& locale-gen en_US.utf8 \
	&& /usr/sbin/update-locale LANG=en_US.UTF-8

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

## This was not needed before but we need it now
ENV DEBIAN_FRONTEND noninteractive

# Now install R and littler, and create a link for littler in /usr/local/bin
# Default CRAN repo is now set by R itself, and littler knows about it too
# r-cran-docopt is not currently in c2d4u so we install from source
RUN apt-get update \
        && apt-get install -y --no-install-recommends \
                 littler \
 		 r-base \
 		 r-base-dev \
 		 r-recommended \
  	&& ln -s /usr/lib/R/site-library/littler/examples/install.r /usr/local/bin/install.r \
 	&& ln -s /usr/lib/R/site-library/littler/examples/install2.r /usr/local/bin/install2.r \
 	&& ln -s /usr/lib/R/site-library/littler/examples/installGithub.r /usr/local/bin/installGithub.r \
 	&& ln -s /usr/lib/R/site-library/littler/examples/testInstalled.r /usr/local/bin/testInstalled.r \
 	&& install.r docopt \
 	&& rm -rf /tmp/downloaded_packages/ /tmp/*.rds \
 	&& rm -rf /var/lib/apt/lists/*

RUN apt-get update; \
    apt-get -y upgrade
RUN apt-get -y install cmake curl
RUN apt-get install -y python3 python3-pip python-pip
RUN apt-get install -y libv8-dev git
RUN apt install -y python3-pip
RUN pip3 install virtualenv keras tensorflow antpyx
## Run an install.R script, if it exists.
RUN if [ -f install.R ]; then R --quiet -f install.R; fi

RUN wget https://github.com/stnava/ITKR/releases/download/v0.5.3.0.1/ITKR_0.5.3_R_x86_64-pc-linux-gnu_R3.6.tar.gz
RUN R CMD INSTALL ITKR_0.5.3_R_x86_64-pc-linux-gnu_R3.6.tar.gz
RUN wget https://github.com/ANTsX/ANTsRCore/releases/download/v0.7.3.0.3/ANTsRCore_0.7.3.1_R_x86_64-pc-linux-gnu_R3.6.tar.gz
RUN R CMD INSTALL ANTsRCore_0.7.3.1_R_x86_64-pc-linux-gnu_R3.6.tar.gz
RUN wget https://github.com/ANTsX/ANTsR/releases/download/v0.5.4.1.2/ANTsR_0.5.4.1_R_x86_64-pc-linux-gnu_R3.6.tar.gz
RUN R CMD INSTALL ANTsR_0.5.4.1_R_x86_64-pc-linux-gnu_R3.6.tar.gz
RUN git clone https://github.com/ANTsX/ANTsRNet.git && R CMD INSTALL ANTsRNet
RUN git clone https://github.com/stnava/patchMatchR.git && R CMD INSTALL patchMatchR
RUN chmod a+rwx *
RUN chmod a+rwx .


CMD ["bash"]
