require File.dirname(__FILE__) + '/test_helper.rb'
require 'find'

class TestCompress < Test::Unit::TestCase
  FINDDIR = File.join(File.dirname(__FILE__), 'data')
  COMPRESSDIR = File.join(File.dirname(__FILE__), 'data', 'compress')
  
  def setup
    @find = Beaver::FindFile.new()
    @find.search(FINDDIR, :recurse => true) do |file|
      @find.add_file(file) if file =~ /foobar/
    end
    @compress = Beaver::Compress.new()
  end

  def test_gzip
    compressed_files = @compress.compress(:gzip, @find.files)
    compressed_files.each do |file|
      assert(FileTest.file?(file), "Compressed file exists.")
      assert(file =~ /.gz$/, "File ends in .gz")
    end
  end
  
  def teardown
    Find.find(COMPRESSDIR) do |file|
      File.unlink(file) if file =~ /\.gz$/
    end
  end
  
end

