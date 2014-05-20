# Mongo Backup

Backup database and upload it to S3, restore tool is included as well. Make sure ```mongodb-client``` package is installed and ```mongodump``` command is available on the production server. If not please run: ```sudo apt-get install mongodb-clients``` — on Ubuntu.

## Setup

Add to ```Gemfile```:

    gem 'mongo-backup'

Add environment variables:

    MONGODB_URL           = ::value::
    S3_BACKUPS_BUCKET     = ::value::
    AWS_ACCESS_KEY_ID     = ::value::
    AWS_SECRET_ACCESS_KEY = ::value::

Add cron job:

    rake mongo:backup

## Rake command available

Do backup:

    rake mongo:backup

List available backups:

    rake mongo:list_backups

Restore from FILE:

    rake mongo:restore FILE=<filename.tag.gz>

Restore latest backup to localhost:

    rake mongo:restore S3_BACKUPS_BUCKET=_ AWS_ACCESS_KEY_ID=_ AWS_SECRET_ACCESS_KEY=_