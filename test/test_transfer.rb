require File.dirname(__FILE__) + '/test_helper.rb'
require 'find'

class TestRename < Test::Unit::TestCase
  TRANSFER_FILE = File.join(TRANSFERDIR, "transfer_file")
  TO_FILE       = File.join(TRANSFERDIR, "new_transfer_file")
  LANDING       = File.join(TRANSFERDIR, "landing")
  LANDING_FILE  = File.join(LANDING, "transfer_file")
  
  def setup
    @transfer = Beaver::Transfer.new
  end
  
  def test_transfer
    if_live_rsync do
      test_ssh
      result = @transfer.transfer([ TRANSFER_FILE ], :with => :scp, :user => ENV["LIVE_RSYNC_USER"], :ssh_key => ENV["LIVE_RSYNC_KEY"], :host => ENV["LIVE_RSYNC_HOST"], :to => LANDING)
      assert(result, "transfer scp command successful")
      assert(FileTest.file?(LANDING_FILE), "#{LANDING_FILE} should exist")
    end
  end
  
  def test_rsync
    if_live_rsync do
      test_ssh
      result = @transfer.rsync(TRANSFER_FILE, ENV["LIVE_RSYNC_USER"], ENV["LIVE_RSYNC_HOST"], LANDING, ENV["LIVE_RSYNC_KEY"])
      assert(result, "rsync command successful")
      assert(FileTest.file?(LANDING_FILE), "#{LANDING_FILE} should exist")
    end
  end
  
  def test_ssh
    if_live_rsync do 
      cmd    = "mkdir -p #{LANDING}"
      result = @transfer.ssh(ENV["LIVE_RSYNC_USER"], ENV["LIVE_RSYNC_HOST"], cmd, ENV["LIVE_RSYNC_KEY"])
      assert(result, "ssh command successful")
      assert(FileTest.directory?(LANDING), "#{LANDING} should exist.")
    end
  end
  
  def test_scp
    if_live_rsync do
      test_ssh
      result = @transfer.scp(TRANSFER_FILE, ENV["LIVE_RSYNC_USER"], ENV["LIVE_RSYNC_HOST"], LANDING, ENV["LIVE_RSYNC_KEY"])
      assert(result, "scp command successful")
      assert(FileTest.file?(LANDING_FILE), "#{LANDING_FILE} should exist")
    end
  end
  
  def if_live_rsync(&block)
    if ENV["LIVE_RSYNC_USER"] && ENV["LIVE_RSYNC_HOST"] && ENV["LIVE_RSYNC_KEY"]
      block.call
    end
  end
  
  def teardown
    File.unlink(LANDING_FILE) if FileTest.file?(LANDING_FILE)
    Dir.delete(LANDING) if FileTest.directory?(LANDING)
  end
 
  
end

