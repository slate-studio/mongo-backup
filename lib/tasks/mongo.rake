namespace :mongo do
  desc "Show list of available backup files"
  task :list_backups => :environment do
    backups.each { |file| puts file.key.gsub('backups/', '') }
  end

  desc "Restore database from backup"
  task :restore => :environment do
    if ENV['FILE']
      restore(ENV['FILE'])
    else
      filename = backups.last.key.gsub('backups/', '')
      restore(filename)
    end
  end

  desc "Backup database and upload to S3 bucket"
  task :backup => :environment do
    # TODO: check if mongodump command is installed on a server
    # sudo apt-get install mongodb-clients

    uri, db_name = parse_uri()
    filename     = Time.now.strftime("%Y-%m-%d_%H-%M-%S.tar.gz")
    backup_cmd   = "mongodump -u #{uri.user} -p #{uri.password} -h #{uri.host}:#{uri.port} -d #{db_name}"

    system "cd /tmp ; #{backup_cmd} ; GZIP=-9 tar -zcvf #{filename} dump/"

    bucket.files.create(key: "backups/#{filename}", body: open("/tmp/#{filename}"))

    system "rm /tmp/#{filename} ; rm -Rf /tmp/dump"
  end

  private

  def connection
    @connection ||= Fog::Storage.new({ provider:              'AWS',
                                       aws_access_key_id:     ENV['AWS_ACCESS_KEY_ID'],
                                       aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'] })
  end

  def backups
    connection.directories.get(ENV['S3_BACKUPS_BUCKET'], prefix: 'backups').files
  end

  def bucket
    connection.directories.new(key: ENV['S3_BACKUPS_BUCKET'])
  end

  def restore(filename)
    s3_file  = bucket.files.get("backups/#{filename}")
    db_name  = ::Mongoid::Sessions.default.options[:database]

    open("/tmp/#{filename}", 'w') { |f| f.binmode ; f.write s3_file.body }

    system "cd /tmp ; tar -xzf /tmp/#{filename}"

    ::Mongoid::Sessions.default.drop

    if Rails.env.production?
      uri, backup_db_name = parse_uri()
      system "mongorestore -u #{uri.user} -p #{uri.password} -h #{uri.host}:#{uri.port} -d #{db_name} /tmp/dump/#{backup_db_name}"
    else
      backup_db_name = Dir.entries('/tmp/dump').select { |file| File.directory? File.join('/tmp/dump', file) }.last
      system "mongorestore -d #{db_name} /tmp/dump/#{backup_db_name}"
    end

    system "rm /tmp/#{filename} ; rm -Rf /tmp/dump"
  end

  def parse_uri
    db_url = ENV['MONGODB_URL'] || ENV['MONGO_URL'] || ENV['MONGODB_URI']

    if db_url.nil?
      puts "ENV['MONGODB_URL'] has to be defined."
      exit
    end

    # use first mongodb server if a few provided
    first_uri = db_url.split(',').first
    uri       = URI.parse(first_uri)
    db_name   = db_url.split('/').last

    return uri, db_name
  end

  # TODO: sync for c66:
  # 1. Get mongo database uri from c66 via API or toolbelt (if possible or clone and make a feature)
  # 2. Check if possible to use with mongodump
  # 3. Parse uri and pass values to mongodump command if not possible usage of uri with mongodump
  # 4. Execute all backup commands with proper values

  #"""mongodump -u admin -p '' -h ds029120-a0.mongolab.com:29120 -d wta
  #   mongo wta --eval "db.dropDatabase()"
  #   mongorestore dump/wta"""
end