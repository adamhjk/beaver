require File.dirname(__FILE__) + '/test_helper.rb'

class TestJob < Test::Unit::TestCase
  
  def setup
    TestHelp.establish_ar
    @job = Beaver::Job.new
  end
  
  def test_set
    result = @job.set(:source => "bmonster")
    assert(result, "Setting the source returned true")
    assert(@job.get(:source) == "bmonster", "Source is bmonster")
  end
  
  def test_add_file
    failed = false
    begin
      @job.add_file(FINDFILE)
    rescue ArgumentError
      failed = true
    end
    set_variables()
    assert(failed, "add_file fails if you haven't set the source.")
    log_obj = @job.add_file(FINDFILE)
    assert(log_obj.kind_of?(ActiveRecord::Base), "Returns active record object")
    assert(log_obj.name == FINDFILE, "File has been added")
  end
  
  def test_find
    set_variables()
    find_files()
    assert(@job.files.length == 3, "Found 3 files")
  end
  
  def test_find_empty
    set_variables()
    failed = false
    begin
      @job.find(FINDDIR) { |file| }
    rescue ArgumentError
      failed = true
    end
    assert(failed, "Exception thrown if no files found")
  end
  
  def test_compress_no_files
    set_variables()
    failed = false
    begin
      @job.compress(:with => :gzip)
    rescue ArgumentError
      failed = true
    end
    assert(failed, "Compress fails without some files")
  end
  
  def test_compress
    set_variables()
    find_files()
    compress_files()
    @job.files.each do |f|
      assert(f.currentfile =~ /\.gz/, "File ends in .gz")
      assert(FileTest.file?(f.currentfile), "Gzip file exists")
    end
  end
  
  def test_rename_no_files
    set_variables()
    failed = false
    begin
      @job.rename(:append => "_monkey")
    rescue ArgumentError
      failed = true
    end
    assert(failed, "Rename fails without some files")
  end
  
  def test_rename_append
    rename_test(:append => "_monkey") do
      @job.files.each do |f|
        assert(f.currentfile =~ /_monkey$/, "Monkey is appended")
      end
    end
  end
  
  def test_rename_prepend
    rename_test(:prepend => "monkey_") do
      @job.files.each do |f|
        assert(f.currentfile =~ /monkey_/, "Monkey is prepended")
      end
    end
  end
  
  def test_rename_both
    rename_test(:append => "_monkey", :prepend => "monkey_") do
      @job.files.each do |f|
        assert(f.currentfile =~ /monkey_.+_monkey$/, "Monkey is on both ends")
      end
    end
  end

  def test_rename_block
    set_variables()
    find_files()
    compress_files()
    @job.rename do |file|
      "clerks_#{file}_dogma"
    end
    @job.files.each do |f|
      assert(f.currentfile =~ /clerks_.+_dogma$/, "Kevin Smith is in the block.")
    end
  end
  
  def test_transfer_no_files
    set_variables()
    failed = false
    begin
      @job.transfer(:with => :scp)
    rescue ArgumentError
      failed = true
    end
    assert(failed, "Transfer fails without any files")
  end
  
  def test_transfer_no_full_args
    set_variables()
    find_files()
    failed = false
    begin
      @job.transfer(:with => :scp)
    rescue ArgumentError
      failed = true
    end
    assert(failed, "Cannot transfer without more arguments than just with")
  end
  
  def test_transfer_inherit
    TestHelp.if_live_tests do
      set_variables()
      find_files()
      @job.set(:transfer_user => ENV["LIVE_USER"])
      @job.set(:transfer_host => ENV["LIVE_HOST"])
      @job.set(:transfer_to   => LANDING)
      @job.set(:transfer_ssh_key  => ENV["LIVE_KEY"])
      result = @job.transfer(:with => :scp)
      assert(result, "Transfer successful")
      assert(FileTest.directory?(LANDING), "#{LANDING} should exist.")
      @job.files.each do |file|
        filename = File.basename(file.name)
        assert(FileTest.file?(File.join(LANDING, filename)), "Files have been transferred")
        File.unlink(File.join(LANDING, filename)) if FileTest.file?(File.join(LANDING, filename))
      end
    end
  end
  
  def test_transfer
    TestHelp.if_live_tests do
      set_variables()
      find_files()
      result = @job.transfer(:with => :scp, :user => ENV["LIVE_USER"], :host => ENV["LIVE_HOST"], :to => LANDING, :ssh_key => ENV["LIVE_KEY"])
      assert(result, "Transfer successful")
      assert(FileTest.directory?(LANDING), "#{LANDING} should exist.")
      @job.files.each do |file|
        filename = File.basename(file.name)
        assert(FileTest.file?(File.join(LANDING, filename)), "Files have been transferred")
        File.unlink(File.join(LANDING, filename)) if FileTest.file?(File.join(LANDING, filename))
      end
    end
  end
  
  def test_delete_no_files
    set_variables()
    failed = false
    begin
      @job.delete()
    rescue ArgumentError
      failed = true
    end
    assert(failed, "Delete fails without any files")
  end
  
  def test_delete
    set_variables()
    find_files()
    compress_files()
    files = @job.files.collect { |f| f.currentfile }
    @job.delete()
    files.each do |file|
      assert(! FileTest.file?(file), "#{file} should not exist")
    end
  end
  
  def test_delete_keep
    set_variables()
    find_files()
    compress_files()
    files = @job.files.collect { |f| f.currentfile }
    @job.delete(:keep => 2)
    files.each do |file|
      assert(! FileTest.file?(file), "#{file} should not exist")
    end
  end
  
  def teardown
    TestHelp.teardown_ar
    TestHelp.delete_compressed_files
    TestHelp.delete_renamed_files
  end
  
  private
    
    def set_variables
      @job.set(:source => "bmonster")
      @job.set(:compress_directory => COMPRESSDIR)
      @job.set(:rename_directory => RENAMEDIR)
    end
    
    def find_files
      @job.find(FINDDIR) do |file|
         @job.add_file(file) if file =~ /foobar/
       end
    end
    
    def compress_files
      @job.compress(:with => :gzip)
    end
    
    def rename_test(args)
      set_variables()
      find_files()
      compress_files()
      @job.rename(args)
      yield
    end
end

