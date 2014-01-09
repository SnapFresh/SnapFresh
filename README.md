# SnapFresh [![Build Status](https://travis-ci.org/jwieringa/AllIncomeFoods.png)](https://travis-ci.org/jwieringa/AllIncomeFoods) [![Code Climate](https://codeclimate.com/github/ysiadf/AllIncomeFoods.png)](https://codeclimate.com/github/ysiadf/AllIncomeFoods)

# Installation and Setup

## Install Dependencies

**Dependencies**

+ Postgres
+ Git
+ Ruby

For Ruby and Git, a good tutorial can be found at [Jumpstart Lab Tutorials](http://tutorials.jumpstartlab.com/topics/environment/environment.html)

For Postgres, see install options depending on your operating system below and follow the instructions.

## Setup

```
$ git clone git@github.com:ysiadf/AllIncomeFoods.git
$ cd AllIncomeFoods
$ bundle install
$ cp config/database.yml.example config/database.yml
$ bundle exec rake db:nuke_pave
```

## Installing Postgres

### Mac Users

  Recommended installation is with [Postgress.app](http://www.postgresapp.com/) or [Homebrew](http://www.brew.sh/). See relative sites for instructions on installation.

### Window Users

  Download and follow the instructions from [Postgres](http://www.enterprisedb.com/products-services-training/pgdownload#windows). When promoted, you will want to install the local version, not the remote server.

### Linux

For Fedora:

```
$ sudo yum install postgresql-server postgresql-client postgresql-docs postgresql-devel
```

### Database Configuration

  For Mac users, be sure to add the following to `config/database.yml` in order to avoid port errors.

```
development:
  host: localhost

test:
  host: localhost
```

  You may need to add or modify additional configurations in `database.yml` depending on how Postgres is setup.

  A for develoment purposes, a username and password are not required unless Postgres is setup to require them. The fields can either be left blank or removed.

## Development Data

  If you only want data for development purposes, then `db:sample` will load a small amount (200 records) that will probably be sufficient for development purposes.

```
$ rake db:sample
```

## Production Data

Download a new data set and load into the database.

```
$ rake db:datarefresh
```

A line should print out every 10K rows that are refreshed - this way you can check on the progress of the script which takes at least 10 min to run.

### Alternate Production Data Load

Alternate way to load the full data (if above steps dont work for some reason):

1. Run `ruby db/cronjob.rb` to fetch all data files, unzip and then produce a single CSV file called "all.csv".

2. Bulk-load into postgres, using this command.

```
$ grep -v '"NULL"' all.csv | psql allincomefoods_dev -c "copy retailers (name, lon, lat, street, city, state, zip, zip_plus_four) from stdin null as 'NULL' csv;"
```

3. Remove all the .zip and .csv files that were created as part of the download process.

\/\/00T! You should be all installed and stuff now.
---------------------------------------------------

# Contribution Guidelines

1. Create a feature branch from develop: `git checkout -b feature/myfeature develop` or `git flow feature start myfeature`
2. Commit and push your changes
3. Submit a pull request to the develop branch

License/Copyright
-----------------

License INFO: - Note, this license applies to all files within the ysiadf/AllIncomeFoods repo.
It is an OSI approved license.

Copyright [2011] [Ysiad Ferreiras, Aaron Bannert, Jeremy Canfield and Michelle Koeth]

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.

You may obtain a copy of the [License](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

See [LICENSE](http://www.github.com/ysiadf/AllIncomeFoods/LICENSE.txt) for details.
