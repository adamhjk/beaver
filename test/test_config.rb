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

require File.dirname(__FILE__) + '/test_helper.rb'

class TestConfig < Test::Unit::TestCase
  
  def test_no_config
    config = Beaver::Config.new()
    assert_kind_of(Beaver::Config, config)
    assert_equal(config.compress_directory, '/var/lib/beaver/compress')
    assert_equal(config.rename_directory, '/var/lib/beaver/rename')
    assert_equal(config.db, { 
      "adapter"  => 'sqlite3', 
      "database" => '/var/lib/beaver/beaver.db', 
    })
    assert_nil(config.transfer_user)
    assert_nil(config.transfer_host)
    assert_nil(config.transfer_ssh_key)
  end
  
  def test_config_from_file
    config = Beaver::Config.new(TestHelp::CONFIGFILE)
    assert_kind_of(Beaver::Config, config)
    assert_equal(config.compress_directory, '/tmp/compress')
    assert_equal(config.rename_directory, '/tmp/rename')
    assert_equal(config.db, {
      "adapter"  => 'sqlite3',
      "database" => '/tmp/beaver.sqlite'
    })
    assert_equal(config.transfer_user, 'adam')
    assert_equal(config.transfer_host, 'localhost')
    assert_equal(config.transfer_ssh_key, 'ssh_key.id')
  end
  
  def setup_database
    config = Beaver::Config.new()
    config.db = {
      "adapter" => 'sqlite3',
      "database" => TestHelp::DBFILE
    }
    config.setup_database
  end

end

