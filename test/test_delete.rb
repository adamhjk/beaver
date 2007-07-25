require File.dirname(__FILE__) + '/test_helper.rb'
require 'find'

class TestRename < Test::Unit::TestCase
  DELETEFILE = File.join(DATADIR, "deletemenow")
  
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

