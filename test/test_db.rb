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

class TestDB < Test::Unit::TestCase
  
  def setup
    TestHelp.establish_ar
  end
  
  def test_db_log
    log = Beaver::DB::Log.new(
      :name => 'fake',
      :shasum => '4e98e2e06bd6006f27fafe30af5ec13a59ad470e',
      :source => 'unit test',
      :status => 'transferring',
      :logdate => Time.now
    )
    assert(log.save, "Created a new log")
    fake_log = Beaver::DB::Log.find_by_name('fake')
    assert(fake_log, "Log can be found by name")
    assert(fake_log.name == 'fake', "Log has correct name")
  end
  
  def teardown
    TestHelp.teardown_ar
  end
end
