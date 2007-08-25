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
require 'find'

class TestDelete < Test::Unit::TestCase
  DELETEFILE = File.join(TestHelp::DATADIR, "deletemenow")
  
  def setup
    file = File.new(DELETEFILE, 'w')
    file.puts "bass is kind of weak beer, but tasty."
    file.close
    
    @delete = Beaver::Delete.new
  end
  
  def test_delete
    @delete.delete([ DELETEFILE ])
    assert(! FileTest.file?(DELETEFILE), "#{DELETEFILE} no longer exists")
  end
 
  def test_delete_file
    @delete.delete_file(DELETEFILE)
    assert(! FileTest.file?(DELETEFILE), "#{DELETEFILE} no longer exists")
  end

end

