begin
  require 'postgresql'
rescue LoadError
  Chef::Log.info("Missing gem 'postgresql'")
end

module Opscode
  module postgresql
    module Database
      def db
        @db ||= ::postgresql.new new_resource.host, new_resource.username, new_resource.password
      end
      def close
        @db.close rescue nil
        @db = nil
      end
    end
  end
end
