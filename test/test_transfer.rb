require File.dirname(__FILE__) + '/test_helper.rb'
require 'find'

class TestRename < Test::Unit::TestCase
  
  def setup
    @transfer = Beaver::Transfer.new
  end
  
  def test_transfer
    TestHelp.if_live_tests do
      test_ssh
      result = @transfer.transfer([ TRANSFER_FILE ], :with => :scp, :user => ENV["LIVE_USER"], :ssh_key => ENV["LIVE_KEY"], :host => ENV["LIVE_HOST"], :to => LANDING)
      assert(result, "transfer scp command successful")
      assert(FileTest.file?(LANDING_FILE), "#{LANDING_FILE} should exist")
    end
  end
  
  def test_rsync
    TestHelp.if_live_tests do
      test_ssh
      result = @transfer.rsync(TRANSFER_FILE, ENV["LIVE_USER"], ENV["LIVE_HOST"], LANDING, ENV["LIVE_KEY"])
      assert(result, "rsync command successful")
      assert(FileTest.file?(LANDING_FILE), "#{LANDING_FILE} should exist")
    end
  end
  
  def test_ssh
    TestHelp.if_live_tests do 
      cmd    = "mkdir -p #{LANDING}"
      result = @transfer.ssh(ENV["LIVE_USER"], ENV["LIVE_HOST"], cmd, ENV["LIVE_KEY"])
      assert(result, "ssh command successful")
      assert(FileTest.directory?(LANDING), "#{LANDING} should exist.")
    end
  end
  
  def test_scp
    TestHelp.if_live_tests do
      test_ssh
      result = @transfer.scp(TRANSFER_FILE, ENV["LIVE_USER"], ENV["LIVE_HOST"], LANDING, ENV["LIVE_KEY"])
      assert(result, "scp command successful")
      assert(FileTest.file?(LANDING_FILE), "#{LANDING_FILE} should exist")
    end
  end
  
  def teardown
    File.unlink(LANDING_FILE) if FileTest.file?(LANDING_FILE)
    Dir.delete(LANDING) if FileTest.directory?(LANDING)
  end
   
end

