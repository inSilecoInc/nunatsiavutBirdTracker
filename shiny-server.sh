#!/bin/sh
# Mettre les commmandes sops pour decrypt les secrets via docker env
Rscript -e "nunatsiavutBirdTracker::run_app(options = list(port = 5000, host = "0.0.0.0"))" 2>&1