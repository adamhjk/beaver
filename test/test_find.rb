require File.dirname(__FILE__) + '/test_helper.rb'

class TestFind < Test::Unit::TestCase
  FINDDIR = File.join(File.dirname(__FILE__), 'data')
  def setup
    @find = Beaver::Find.new(File.dirname(__FILE__))
  end

  def test_db_log
    
  end

end
