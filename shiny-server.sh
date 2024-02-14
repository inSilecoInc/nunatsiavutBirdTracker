#!/bin/sh
Rscript -e "shiny::runApp(port = 5000, host = '0.0.0.0')" 2>&1