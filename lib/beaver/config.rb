# Author:: Adam Jacob (<adam@hjksolutions.com>)
# Copyright:: Copyright (c) 2007 HJK Solutions, LLC
# License:: GNU General Public License version 2.1
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2.1
# as published by the Free Software Foundation.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

require 'yaml'
require 'active_record'

module Beaver
  
  # Deletes files
  class Config    
    attr_accessor :db, :compress_directory, :rename_directory, 
                  :transfer_user, :transfer_host, :transfer_ssh_key, :log_level
    
   #compress_directory: COMPRESSDIR
   #rename_directory: RENAMEDIR
   #transfer_user: ENV["LIVE_USER"]
   #transfer_host: host
   #transfer_ssh_key: sshkey
   #db:
   #  adapter: sqlite3
   #  database: db/beaver.sqlite
   
    # Creates a new Beaver::Config object.
    def initialize(config_file=nil)
      @compress_directory = "/var/lib/beaver/compress"
      @rename_directory   = "/var/lib/beaver/rename"
      @db = {
        "adapter" => 'sqlite3',
        "database" => '/var/lib/beaver/beaver.db'
      }
      @transfer_user = nil
      @transfer_host = nil
      @transfer_ssh_key = nil
      @log_level = "ERROR"
      load(config_file) if config_file
    end
    
    def load(config_file)
      full_path = File.expand_path(config_file)
      if ! FileTest.file?(full_path)
        raise "Cannot find #{config_file}!" 
      end
      config = YAML.load_file(full_path)
      raise "Config must evaluate to a hash!" unless config.kind_of?(Hash)
      @compress_directory = config["compress_directory"] if config.has_key?("compress_directory") 
      @rename_directory = config["rename_directory"] if config.has_key?("rename_directory")
      @db = config["db"] if config.has_key?("db")
      @transfer_user = config["transfer_user"] if config.has_key?("transfer_user")
      @transfer_host = config["transfer_host"] if config.has_key?("transfer_host")
      @transfer_ssh_key = config["transfer_ssh_key"] if config.has_key?("transfer_ssh_key")
    end
    
    def make_missing_dirs
      mkdir(File.dirname(@db["database"]))
      mkdir(@compress_directory)
      mkdir(@rename_directory)
    end
    
    def setup_database()
      ActiveRecord::Base.establish_connection(@db) 
      ActiveRecord::Base.logger = Logger.new(STDOUT)
      ActiveRecord::Base.logger.sev_threshold = Logger::FATAL  
    end
    
    def migrate_database(migrations_path=nil)
      migrations_path = find_migrations unless migrations_path
      ActiveRecord::Migration.verbose = false
      ActiveRecord::Migrator.migrate(
        File.join(migrations_path),
        nil  
      )
    end
    
    private
      
      def mkdir(dir)
        to_make = File.expand_path(dir)
        unless system("mkdir -p #{to_make}")
          raise "Cannot create #{to_make}: #{$?}"
        end
      end
      
      def find_migrations
        install_dir = `gem env | grep 'INSTALLATION DIRECTORY'`
        if install_dir =~ /- INSTALLATION DIRECTORY: (.+)/
          gem_dir = $1
          gem_dir.chomp!
          beaver_dir = File.join(gem_dir, 'beaver-' + Beaver::VERSION::STRING, 'db', 'migrate')
          return beaver_dir if FileTest.directory?(beaver_dir)
        end
        beaver_dir = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'db', 'migrate'))
        return beaver_dir if FileTest.directory?(beaver_dir)
        raise "I cannot find the migrations!"
      end
      
  end
end