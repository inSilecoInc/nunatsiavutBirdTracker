# Base R Shiny image
FROM rocker/shiny:4.3.0

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    libproj-dev \
    libudunits2-dev \
    libgdal-dev \ 
    libgeos-dev \ 
    libsqlite0-dev 

# Install .deb de sops
# via apt

RUN install2.r remotes
RUN Rscript -e 'remotes::install_version("bslib", upgrade = "never", version = "0.5.1", repos = "https://packagemanager.posit.co/cran/__linux__/jammy/latest")'
RUN Rscript -e 'remotes::install_version("config", upgrade = "never", version = "0.3.2", repos = "https://packagemanager.posit.co/cran/__linux__/jammy/latest")'
RUN Rscript -e 'remotes::install_version("DT", upgrade = "never", version = "0.31", repos = "https://packagemanager.posit.co/cran/__linux__/jammy/latest")'
RUN Rscript -e 'remotes::install_version("golem", upgrade = "never", version = "0.4.1", repos = "https://packagemanager.posit.co/cran/__linux__/jammy/latest")'
RUN Rscript -e 'remotes::install_version("mapedit", upgrade = "never", version = "0.6.0", repos = "https://packagemanager.posit.co/cran/__linux__/jammy/latest")'
RUN Rscript -e 'remotes::install_version("markdown", upgrade = "never", version = "1.12", repos = "https://packagemanager.posit.co/cran/__linux__/jammy/latest")'
RUN Rscript -e 'remotes::install_version("osmdata", upgrade = "never", version = "0.2.5", repos = "https://packagemanager.posit.co/cran/__linux__/jammy/latest")'
RUN Rscript -e 'remotes::install_version("rmarkdown", upgrade = "never", version = "2.25", repos = "https://packagemanager.posit.co/cran/__linux__/jammy/latest")'
RUN Rscript -e 'remotes::install_version("shinyjs", upgrade = "never", version = "2.1", repos = "https://packagemanager.posit.co/cran/__linux__/jammy/latest")'

# Install application package
RUN mkdir /build_zone
ADD . /build_zone
WORKDIR /build_zone

RUN Rscript -e 'remotes::install_local(upgrade = "never", depedencies = TRUE)'
WORKDIR /usr
RUN rm -rf /build_zone

# Copy shiny app into the Docker image
COPY . /srv/shiny-server/

# Copy configuration files into the Docker image
COPY shiny-server.conf  /etc/shiny-server/shiny-server.conf

# Set Google service account credentials
COPY nunatsiavut-birds-f33436183827.json /srv/shiny-server/nunatsiavut-birds-f33436183827.json
ENV GOOGLE_APPLICATION_CREDENTIALS=/srv/shiny-server/nunatsiavut-birds-f33436183827.json

# Expose the application port
EXPOSE 5000

USER shiny

ENTRYPOINT ["/usr/bin/shiny-server"]
