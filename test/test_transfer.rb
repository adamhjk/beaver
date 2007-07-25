require File.dirname(__FILE__) + '/test_helper.rb'
require 'find'

class TestRename < Test::Unit::TestCase
  
  def setup
    @transfer = Beaver::Transfer.new
  end
 
  def test_rsync
    @transfer.rsync()
  end
end

