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

require 'active_record'  
require 'yaml'  

namespace :db do 
  desc "Migrate the database through scripts in db/migrate. Target specific version with VERSION=x"  
  task :migrate => :environment do  
    ActiveRecord::Migrator.migrate('db/migrate', ENV["VERSION"] ? ENV["VERSION"].to_i : nil )  
  end  
 
  task :environment do 
    ActiveRecord::Base.establish_connection(
      YAML::load(File.open('config/database.yml'))
    )  
    ActiveRecord::Base.logger = Logger.new(File.open('logs/database.log', 'a'))  
  end
end