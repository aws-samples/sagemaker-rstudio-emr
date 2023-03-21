#This package depends on and may incorporate or retrieve a number of third-party
#software packages (such as open source packages) at install-time or build-time
#or run-time ("External Dependencies"). The External Dependencies are subject to
#license terms that you must accept in order to use this package. If you do not
#accept all of the applicable license terms, you should not use this package. We
#recommend that you consult your company’s open source approval policy before
#proceeding.

#Provided below is a list of External Dependencies and the applicable license
#identification as indicated by the documentation associated with the External
#Dependencies as of Amazon's most recent review.

#THIS INFORMATION IS PROVIDED FOR CONVENIENCE ONLY. AMAZON DOES NOT PROMISE THAT
#THE LIST OR THE APPLICABLE TERMS AND CONDITIONS ARE COMPLETE, ACCURATE, OR
#UP-TO-DATE, AND AMAZON WILL HAVE NO LIABILITY FOR ANY INACCURACIES. YOU SHOULD
#CONSULT THE DOWNLOAD SITES FOR THE EXTERNAL DEPENDENCIES FOR THE MOST COMPLETE
#AND UP-TO-DATE LICENSING INFORMATION.

#YOUR USE OF THE EXTERNAL DEPENDENCIES IS AT YOUR SOLE RISK. IN NO EVENT WILL
#AMAZON BE LIABLE FOR ANY DAMAGES, INCLUDING WITHOUT LIMITATION ANY DIRECT,
#INDIRECT, CONSEQUENTIAL, SPECIAL, INCIDENTAL, OR PUNITIVE DAMAGES (INCLUDING
#FOR ANY LOSS OF GOODWILL, BUSINESS INTERRUPTION, LOST PROFITS OR DATA, OR
#COMPUTER FAILURE OR MALFUNCTION) ARISING FROM OR RELATING TO THE EXTERNAL
#DEPENDENCIES, HOWEVER CAUSED AND REGARDLESS OF THE THEORY OF LIABILITY, EVEN
#IF AMAZON HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES. THESE LIMITATIONS
#AND DISCLAIMERS APPLY EXCEPT TO THE EXTENT PROHIBITED BY APPLICABLE LAW.


#R Packages and Software may be under the GPLv3


# Base OS
FROM public.ecr.aws/amazonlinux/amazonlinux:2

# Required system packages
RUN yum update -y && \
    amazon-linux-extras install -y epel && \
    yum install -y  \
    epel-release \
    libcurl-devel \
    libuser-devel \
    libxml2-devel \
    openssl-devel \
    libpng-dev \
    postgresql-libs \
    openjdk-11-jdk \
    rrdtool \
    tar \
    which \
    vim \
    git \
    sudo && \
    yum clean all

# RStudio Workbench session components
ARG RSW_VERSION=2022.02.2-485.pro2
ARG RSW_NAME=rstudio-workbench-rhel
ARG RSW_DOWNLOAD_URL=https://s3.amazonaws.com/rstudio-ide-build/server/centos7/x86_64
RUN curl -o rstudio-workbench.rpm ${RSW_DOWNLOAD_URL}/${RSW_NAME}-${RSW_VERSION}-x86_64.rpm  && \
    yum install -y rstudio-workbench.rpm && \
    rm rstudio-workbench.rpm && \
    yum clean all && \
    rm -rf /var/lib/rstudio-server/r-versions
EXPOSE 8788/tcp

# Install R and packages
ARG R_VERSION=4.2.0
RUN curl -O https://cdn.rstudio.com/r/centos-7/pkgs/R-${R_VERSION}-1-1.x86_64.rpm && \
    yum install -y R-${R_VERSION}-1-1.x86_64.rpm && \
    yum clean all && \
    rm -rf R-${R_VERSION}-1-1.x86_64.rpm
COPY r-packages.txt .
RUN /opt/R/${R_VERSION}/bin/R -e 'install.packages(readLines("r-packages.txt"), repos="https://packagemanager.rstudio.com/cran/__linux__/centos7/latest")'
RUN rm r-packages.txt

# Install Python and libraries
RUN yum update -y && \
    amazon-linux-extras enable python3.8 && \
    yum install -y python3.8 python38-devel && \
    ln -s /usr/bin/python3.8 /usr/bin/python3 && \
    yum clean all
COPY requirements.txt .
RUN python3 -m pip install --upgrade pip && \
    python3 -m pip install --no-user --ignore-installed --no-binary='numpy' 'numpy' && \
    python3 -m pip install -r requirements.txt
RUN rm requirements.txt

# RStudio ODBC drivers
ARG DRIVERS_VERSION=2021.10.0-1
RUN yum update -y && \
    yum install -y unixODBC unixODBC-devel && \
    yum clean all
RUN curl -O https://drivers.rstudio.org/7C152C12/installer/rstudio-drivers-${DRIVERS_VERSION}.el7.x86_64.rpm && \
    yum install -y rstudio-drivers-${DRIVERS_VERSION}.el7.x86_64.rpm && \
    yum clean all && \
    rm -f rstudio-drivers-${DRIVERS_VERSION}.el7.x86_64.rpm && \
    cp /opt/rstudio-drivers/odbcinst.ini.sample /etc/odbcinst.ini
ARG R_VERSION=4.2.0
RUN /opt/R/${R_VERSION}/bin/R -e 'install.packages("odbc", repos="https://packagemanager.rstudio.com/cran/__linux__/centos7/latest")'

# Locale configuration
RUN yum update -y && \
    yum install -y glibc-locale-source glibc-langpack-en && \
    yum clean all
RUN localedef -i en_US -f UTF-8 en_US.UTF-8
ENV TZ America/New_York
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Set default env values
ENV RSTUDIO_CONNECT_URL ""
ENV RSTUDIO_PACKAGE_MANAGER_URL ""
ENV RETICULATE_MINICONDA_ENABLED FALSE

COPY ["r-versions", "/etc/rstudio/"]
COPY ["Connect to Amazon EMR Cluster.R", "/etc/rstudio/connections/"]
COPY ["session-startup.sh", "/opt/r-sessions/"]
COPY ["rstudio-sparklyr-code-walkthrough.Rmd", "/opt/r-sessions/"]
