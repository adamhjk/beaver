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

class TestTransfer < Test::Unit::TestCase
  
  def setup
    @transfer = Beaver::Transfer.new
  end
  
  def test_transfer
    TestHelp.if_live_tests do
      test_ssh
      result = @transfer.transfer([ TestHelp::TRANSFER_FILE ], :with => :scp, :user => ENV["LIVE_USER"], :ssh_key => ENV["LIVE_KEY"], :host => ENV["LIVE_HOST"], :to => TestHelp::LANDING)
      assert(result, "transfer scp command successful")
      assert(FileTest.file?(TestHelp::LANDING_FILE), "#{TestHelp::LANDING_FILE} should exist")
    end
  end
  
  def test_rsync
    TestHelp.if_live_tests do
      test_ssh
      result = @transfer.rsync(TestHelp::TRANSFER_FILE, ENV["LIVE_USER"], ENV["LIVE_HOST"], TestHelp::LANDING, ENV["LIVE_KEY"])
      assert(result, "rsync command successful")
      assert(FileTest.file?(TestHelp::LANDING_FILE), "#{TestHelp::LANDING_FILE} should exist")
    end
  end
  
  def test_ssh
    TestHelp.if_live_tests do 
      cmd    = "mkdir -p #{TestHelp::LANDING}"
      result = @transfer.ssh(ENV["LIVE_USER"], ENV["LIVE_HOST"], cmd, ENV["LIVE_KEY"])
      assert(result, "ssh command successful")
      assert(FileTest.directory?(TestHelp::LANDING), "#{TestHelp::LANDING} should exist.")
    end
  end
  
  def test_scp
    TestHelp.if_live_tests do
      test_ssh
      result = @transfer.scp(TestHelp::TRANSFER_FILE, ENV["LIVE_USER"], ENV["LIVE_HOST"], TestHelp::LANDING, ENV["LIVE_KEY"])
      assert(result, "scp command successful")
      assert(FileTest.file?(TestHelp::LANDING_FILE), "#{TestHelp::LANDING_FILE} should exist")
    end
  end
  
  def test_scp
    TestHelp.if_live_tests do
      test_cp
      result = @transfer.cp(TestHelp::TRANSFER_FILE, ENV["LIVE_USER"], ENV["LIVE_HOST"], TestHelp::LANDING, ENV["LIVE_KEY"])
      assert(result, "cp command successful")
      assert(FileTest.file?(TestHelp::LANDING_FILE), "#{TestHelp::LANDING_FILE} should exist")
    end
  end
  
  def teardown
    File.unlink(TestHelp::LANDING_FILE) if FileTest.file?(TestHelp::LANDING_FILE)
    Dir.delete(TestHelp::LANDING) if FileTest.directory?(TestHelp::LANDING)
  end
   
end

