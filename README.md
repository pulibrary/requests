# PUL Requests Engine

[![Build Status](https://travis-ci.org/pulibrary/requests.svg?branch=master)](https://travis-ci.org/pulibrary/requests)

## Dependencies

The engine requires a working copy of marc_liberation aka bibdata to be running. Defaults to https://bibdata.princeton.edu. If you wish to override that value while doing development work and point a local working copy you can set your local environment variable of ```BIBDATA_BASE``` to the root of the marc_liberation application you want to work with. 

## To Install for Development

After you've cloned the repo:

```
$ bundle install
$ rake engine_cart:regenerate
$ rake spec
```

## Install in Production

* Add ```gem 'requests', :git 'git@github.com:pulibrary/requests.git'```
* ```bundle install```
* ```rails generate requests:install```

This project rocks and uses MIT-LICENSE.