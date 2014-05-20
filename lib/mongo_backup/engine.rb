module MongoBackup
  module Rails
    class Engine < ::Rails::Engine
      isolate_namespace MongoBackup::Rails
    end
  end
end