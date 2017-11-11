# GeoDiver

[![Build Status](https://travis-ci.org/GeoDiver/GeoDiver.svg?branch=master)](https://travis-ci.org/GeoDiver/GeoDiver)
[![Scrutinizer Code Quality](https://scrutinizer-ci.com/g/GeoDiver/GEODiver/badges/quality-score.png?b=master)](https://scrutinizer-ci.com/g/GeoDiver/GEODiver/?branch=master)

## Introduction

GeoDiver is a web app that allows users to easily analyse GEO datasets.

## Installation

Feel free to give us a shout on the github issues, if you would like more help than that below.

### Installation Requirements

* Ruby (>= 2.2.0)
  * Recommended to use [rvm](https://rvm.io/rvm/install) to install ruby
* R (=3.3.2)
  * https://cran.r-project.org
* NodeJs (>= 7.7)
* bionode-ncbi (>= 2.0)
* jq (>= 1.5)

### Google API Setup

In order to use the Google Login System (recommended), you need register with Google API to recieve a key and secret key (don't forget to keep your secret key a secret!)

1. Go to 'https://console.developers.google.com'
1. Select your project or create a new one (in the top left hand corner).
1. Click on the menu button on the top left, and click on 'API Manager'.
1. Click on 'Library' in the left side bar.
1. In the search bar, type in "Contacts API" and then "Google+ API".
1. When it is shown, click on the API name and then select 'Enable'.
1. Once enabled, go back to the previous screen and search for the second API.
1. After, enabling both APIs, click on 'Credentials' in the side bar.
1. Next select the "OAuth consent screen" tab on top, and provide an 'EMAIL ADDRESS' and a 'PRODUCT NAME'
1. Press 'Save' (This may automatically take you to step 12)
1. Next select the 'Credentials' tab on top and click on 'Create Credentials' and then 'OAuth Client ID'.
1. Under Application type, select 'Web Application'
1. Select a name for your application (e.g. GeoDiver)
1. Under Authorised Javscript origins, add 'http://localhost:9292' (and other domain name you wish to use, including with and without 'www')
1. Next, under Authorised redirect URIs add 'http://localhost:9292/auth/google_oauth2/callback'.
1. Copy Client ID and Client Secret.

### GeoDiver Installation

Simply run the following command in the terminal.

```bash
# Clone the repository.
git clone https://github.com/GeoDiver/GEODiver

# Move into GeoDiver source directory.
cd GEODiver

# Initialize git submodules
git submodule update --init --remote 

# Install R dependencies & Build and install the latest version of the webapp.
rake install 

# Start the web app
# Make sure you replace $CLIENTID and $CLIENTSECRET with the actual values that you copied above.
passenger start --envvar GOOGLE_KEY=$CLIENTID --envvar GOOGLE_SECRET=$CLIENTSECRET -p 9292 -e production --sticky-sessions -d
```

#### Running From Source (Not Recommended)

It is also possible to run from source. However, this is not recommended.

```bash
# After cloning the web app and moving into the source directory 
# Install bundler
gem install bundler

# Use bundler to install dependencies
bundle install

# Optional: run tests and build the gem from source
bundle exec rake

# Run GeoDiver
bundle exec passenger start -h
# note that `bundle exec` executes GeoDiver in the context of the bundle

# Alternatively run Geodiver using the command line interface
bundle exec geodiver -h
```

## Launch GeoDiver

To configure and launch Geodiver, run the following from a command line from the GeoDiver root folder.

```bash
bundle exec passenger start -h
```

That's it! Open http://localhost:9292/ and start using GeoDiver!

## Advanced Usage

See `$ passenger start -h` for more information on all the options available when running GeoDiver.

## Config file

A Config file can be used to specify arguments - the default location of this file is in the home directory at `~/.geodiver.conf`. An examplar of the config file can be seen below.

```yaml
---
:num_threads: 8
:port: '9292'
:host: 0.0.0.0
:gd_serve_dir: "/Users/ismailm/.geodiver"
:devel: true
```

<hr>

This program was developed at [QMUL](http://sbcs.qmul.ac.uk) as part of the [Bioinformatics Masters Course](http://www.qmul.ac.uk/postgraduate/taught/coursefinder/courses/121410.html).

## Easy setup using Docker (alternative)

If you run into issues trying to setup the above environment to run GeoDiver, we also provide a solution with Docker.

First, make sure your shell environment has your Google credentials (see [Google API Setup](#google-api-setup))

```bash
export GOOGLE_KEY=YOUR-GOOGLE-API-KEY
export GOOGLE_SECRET=YOUR-GOOGLE-API-SECRET
```

Run GeoDiver Docker container using image from Docker registry (fetched on first run)

```bash
docker run --rm -it -p 9292:9292 -v $(pwd):/root/.geodiver -e GOOGLE_KEY -e GOOGLE_SECRET geodiver/geodiver
```

Or, build your own Docker image locally from our Dockerfile

```bash
# Build local image
git clone git@github.com:GeoDiver/GeoDiver.git
cd GeoDiver
docker build -t geodiver .

# Run container using local image
docker run --rm -it -p 9292:9292 -v $(pwd):/root -e GOOGLE_KEY -e GOOGLE_SECRET geodiver
```