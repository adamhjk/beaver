# Author:: Adam Jacob (<adam@hjksolutions.com>)
# Copyright:: Copyright (c) 2007 HJK Solutions, LLC
# License:: GNU General Public License version 2.1
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2.1
# as published by the Free Software Foundation.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

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
  
  def test_want
    result = @job.set(:kings_of_leon => "good band")
    assert(@job.get(:kings_of_leon) == "good band", 'Could not set value')
    assert_nothing_raised(ArgumentError) { @job.want(:kings_of_leon) }
    assert_raise(ArgumentError) { @job.want(:starbucks) }
  end
  
  def test_add_file
    failed = false
    begin
      @job.add_file(TestHelp::FINDFILE)
    rescue ArgumentError
      failed = true
    end
    set_variables()
    assert(failed, "add_file fails if you haven't set the source.")
    log_obj = @job.add_file(TestHelp::FINDFILE)
    assert(log_obj.kind_of?(ActiveRecord::Base), "Returns active record object")
    assert(log_obj.name == TestHelp::FINDFILE, "File has been added")
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
      @job.find(TestHelp::FINDDIR) { |file| }
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
      @job.set(:transfer_to   => TestHelp::LANDING)
      @job.set(:transfer_ssh_key  => ENV["LIVE_KEY"])
      result = @job.transfer(:with => :scp)
      assert(result, "Transfer successful")
      assert(FileTest.directory?(TestHelp::LANDING), "#{TestHelp::LANDING} should exist.")
      @job.files.each do |file|
        filename = File.basename(file.name)
        assert(FileTest.file?(File.join(TestHelp::LANDING, filename)), "Files have been transferred")
        File.unlink(File.join(TestHelp::LANDING, filename)) if FileTest.file?(File.join(TestHelp::LANDING, filename))
      end
    end
  end
  
  def test_transfer
    TestHelp.if_live_tests do
      set_variables()
      find_files()
      result = @job.transfer(:with => :scp, :user => ENV["LIVE_USER"], :host => ENV["LIVE_HOST"], :to => TestHelp::LANDING, :ssh_key => ENV["LIVE_KEY"])
      assert(result, "Transfer successful")
      assert(FileTest.directory?(TestHelp::LANDING), "#{TestHelp::LANDING} should exist.")
      @job.files.each do |file|
        filename = File.basename(file.name)
        assert(FileTest.file?(File.join(TestHelp::LANDING, filename)), "Files have been transferred")
        File.unlink(File.join(TestHelp::LANDING, filename)) if FileTest.file?(File.join(TestHelp::LANDING, filename))
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
    create_files_to_delete()
    set_variables()
    find_files_delete()
    compress_files()
    files = @job.files.collect { |f| [ f.currentfile, f.name ] }
    @job.delete()
    files.each do |file|
      assert(! FileTest.file?(file[0]), "#{file[0]} should not exist")
      assert(! FileTest.file?(file[1]), "#{file[1]} should not exist")
    end
  end
  
  def test_delete_keep
    create_files_to_delete()
    set_variables()
    find_files_delete()
    compress_files()
    files = @job.files.collect { |f| [ f.currentfile, f.name ] }
    @job.delete(:keep => 2)
    waiting = Beaver::DB::Log.find(:all, :conditions => { :status => "waiting" })
    should_keep = waiting.length
    waiting.each do |file|
      assert(FileTest.file?(file.name), "#{file.name} File should exist")
      assert(FileTest.file?(file.currentfile), "#{file.currentfile} File should exist")
      File.unlink(file.name)
      File.unlink(file.currentfile)
      files.delete([ file.currentfile, file.name ])
    end
    files.each do |file|
      assert(! FileTest.file?(file[0]), "#{file[0]} should not exist")
      assert(! FileTest.file?(file[1]), "#{file[1]} should not exist")
    end
    @job.cleanup
    waiting = Beaver::DB::Log.find(:all, :conditions => { :status => "waiting" })
    assert(should_keep == waiting.length, "Still have the waiting files after cleanup")
  end
  
  def test_load
    TestHelp.if_live_tests do 
      @job.load(TestHelp::BEAVERSCRIPT)
      @job.files do |file|
        assert(file.status == "waiting", "Status should be waiting")
        assert(FileTest.file?(file.name), "Original file should exist")
        assert(FileTest.file?(file.currentfile), "Current file should exist")
      end
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
      @job.set(:compress_directory => TestHelp::COMPRESSDIR)
      @job.set(:rename_directory => TestHelp::RENAMEDIR)
    end
    
    def find_files
      @job.find(TestHelp::FINDDIR) do |file|
         @job.add_file(file) if file =~ /foobar/
       end
    end
    
    def create_files_to_delete
      [ "test_3.log", "test_2.log", "test_1.log" ].each do |name|
        File.open(File.join(TestHelp::DELETEDIR, name), "w") do |f|
          f.puts "testing testing testing"
        end
        sleep 1
      end
    end
    
    def find_files_delete
      @job.find(TestHelp::DELETEDIR) do |file|
         @job.add_file(file) if FileTest.file?(file)
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

