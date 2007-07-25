require File.dirname(__FILE__) + '/test_helper.rb'

class TestFind < Test::Unit::TestCase
  FINDDIR = File.join(File.dirname(__FILE__), 'data')
  
  def setup
    @find = Beaver::FindFile.new()
  end

  def test_find
    @find.search(FINDDIR, :recurse => true) do |file|
      @find.add_file(file) if file =~ /foobar/
    end
    assert(@find.files.length == 3, "Found 3 files")
  end
  
end

