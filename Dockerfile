# Base R Shiny image
FROM rocker/shiny:4.3.0

# Set credentials from github secrets
ARG MOVEBANK_USER
ARG MOVEBANK_PW

ENV MOVEBANK_USER=${MOVEBANK_USER}
ENV MOVEBANK_PW=${MOVEBANK_PW}

# Install system dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    libproj-dev \
    libudunits2-dev \
    libgdal-dev \
    libgeos-dev \
    libsqlite0-dev \
    wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install sops
RUN wget -q https://github.com/getsops/sops/releases/download/v3.8.1/sops_3.8.1_amd64.deb \
    && dpkg -i sops_3.8.1_amd64.deb \
    && rm sops_3.8.1_amd64.deb

# Install remotes for R package installations
RUN install2.r --error remotes

# Install required R packages from Imports in DESCRIPTION
RUN Rscript -e 'remotes::install_version("arrow", version = "14.0.0.2", repos = "https://packagemanager.posit.co/cran/__linux__/jammy/latest")' \
    && Rscript -e 'remotes::install_version("bslib", version = "0.5.1", repos = "https://packagemanager.posit.co/cran/__linux__/jammy/latest")' \
    && Rscript -e 'remotes::install_version("cli", version = "3.6.1", repos = "https://packagemanager.posit.co/cran/__linux__/jammy/latest")' \
    && Rscript -e 'remotes::install_version("config", version = "0.3.2", repos = "https://packagemanager.posit.co/cran/__linux__/jammy/latest")' \
    && Rscript -e 'remotes::install_version("dplyr", version = "1.1.4", repos = "https://packagemanager.posit.co/cran/__linux__/jammy/latest")' \
    && Rscript -e 'remotes::install_version("fs", version = "1.6.3", repos = "https://packagemanager.posit.co/cran/__linux__/jammy/latest")' \
    && Rscript -e 'remotes::install_version("glue", version = "1.6.2", repos = "https://packagemanager.posit.co/cran/__linux__/jammy/latest")' \
    && Rscript -e 'remotes::install_version("golem", version = "0.4.1", repos = "https://packagemanager.posit.co/cran/__linux__/jammy/latest")' \
    && Rscript -e 'remotes::install_version("googleCloudStorageR", version = "0.7.0", repos = "https://packagemanager.posit.co/cran/__linux__/jammy/latest")' \
    && Rscript -e 'remotes::install_version("htmltools", version = "0.5.8.1", repos = "https://packagemanager.posit.co/cran/__linux__/jammy/latest")' \
    && Rscript -e 'remotes::install_version("leaflet", version = "2.2.1", repos = "https://packagemanager.posit.co/cran/__linux__/jammy/latest")' \
    && Rscript -e 'remotes::install_version("leaflet.extras2", version = "1.2.2", repos = "https://packagemanager.posit.co/cran/__linux__/jammy/latest")' \
    && Rscript -e 'remotes::install_version("lubridate", version = "1.9.3", repos = "https://packagemanager.posit.co/cran/__linux__/jammy/latest")' \
    && Rscript -e 'remotes::install_version("markdown", version = "1.12", repos = "https://packagemanager.posit.co/cran/__linux__/jammy/latest")' \
    && Rscript -e 'remotes::install_version("move", version = "4.2.4", repos = "https://packagemanager.posit.co/cran/__linux__/jammy/latest")' \
    && Rscript -e 'remotes::install_version("purrr", version = "1.0.2", repos = "https://packagemanager.posit.co/cran/__linux__/jammy/latest")' \
    && Rscript -e 'remotes::install_version("pkgload", version = "1.3.3", repos = "https://packagemanager.posit.co/cran/__linux__/jammy/latest")' \
    && Rscript -e 'remotes::install_version("rmarkdown", version = "2.25", repos = "https://packagemanager.posit.co/cran/__linux__/jammy/latest")' \
    && Rscript -e 'remotes::install_version("sf", version = "1.0.14", repos = "https://packagemanager.posit.co/cran/__linux__/jammy/latest")' \
    && Rscript -e 'remotes::install_version("stringr", version = "1.5.1", repos = "https://packagemanager.posit.co/cran/__linux__/jammy/latest")' \
    && Rscript -e 'remotes::install_version("shiny", version = "1.7.4", repos = "https://packagemanager.posit.co/cran/__linux__/jammy/latest")' \
    && Rscript -e 'remotes::install_version("shinyjs", version = "2.1", repos = "https://packagemanager.posit.co/cran/__linux__/jammy/latest")'

# Install application package
RUN mkdir /build_zone
COPY . /build_zone
WORKDIR /build_zone

RUN Rscript -e 'remotes::install_local(upgrade = "never", dependencies = TRUE)'

# Clean up build zone after installing
WORKDIR /usr
RUN rm -rf /build_zone

# Copy Shiny app into the Docker image
RUN rm -rf /srv/shiny-server/*
COPY . /srv/shiny-server/

# Copy configuration files into the Docker image
COPY shiny-server.conf /etc/shiny-server/shiny-server.conf

# Set Google service account credentials
COPY google_api_key.json /srv/shiny-server/google_api_key.json
ENV GOOGLE_APPLICATION_CREDENTIALS=/srv/shiny-server/google_api_key.json

# Expose the application port (default Shiny server port)
EXPOSE 3838

# Set permissions for shiny user and switch to shiny user
RUN chown -R shiny:shiny /srv/shiny-server
USER shiny
