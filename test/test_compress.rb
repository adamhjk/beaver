require File.dirname(__FILE__) + '/test_helper.rb'
require 'find'

class TestCompress < Test::Unit::TestCase
  
  def setup
    @find = Beaver::FindFile.new()
    @find.search(FINDDIR, :recurse => true) do |file|
      @find.add_file(file) if file =~ /foobar/
    end
    @compress = Beaver::Compress.new(COMPRESSDIR)
  end
  
  def test_no_compressdir
    failed = false
    begin
      c = Beaver::Compress.new('/monkeybutt')
    rescue ArgumentError
      failed = true
    end
    assert(failed, "Compress dies on missing directory")
  end

  def test_gzip
    compressed_files = @compress.gzip(@find.files)
    compressed_files.each do |file|
      assert(FileTest.file?(file), "Compressed file exists.")
      assert(file =~ /.gz$/, "File ends in .gz")
    end
  end

  def test_compress
    compressed_files = @compress.compress(@find.files, :with => :gzip)
    compressed_files.each do |file|
      assert(FileTest.file?(file), "Compressed file exists.")
      assert(file =~ /.gz$/, "File ends in .gz")
    end
  end
  
  def teardown
    TestHelp.delete_compressed_files
  end
  
end

