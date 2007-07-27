require File.dirname(__FILE__) + '/test_helper.rb'

class TestFind < Test::Unit::TestCase
  
  def setup
    @find = Beaver::FindFile.new()
  end

  def test_find
    file_list = Array.new
    @find.search(FINDDIR, :recurse => true) do |file|
      file_list << file
      @find.add_file(file) if file =~ /foobar/
    end
    check_files(file_list)
  end
  
  def test_find_datetime
    file_list = Array.new
    @find.search(FINDDIR, :recurse => true) do |file|
      file_list << file
      @find.add_file(file, "2007-10-10") if file =~ /foobar/
    end
    check_files(file_list)
  end
  
  private
  
    def check_files(file_list) 
      assert(@find.files.length == 3, "Found 3 files")
      @find.files.each do |farray|
        assert(file_list.detect { |f| f == farray[0] }, "File is in the list")
        assert(farray[1].kind_of?(Time), "File datetime is Time")
        assert(farray[2] =~ /\w{40}/, "File has a SHA1 Hash.")
      end
    end
  
end

