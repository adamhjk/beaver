require File.dirname(__FILE__) + '/test_helper.rb'
require 'find'

class TestRename < Test::Unit::TestCase
  
  def setup
    @filenames = [ File.join(RENAMEDIR, "fishheads") ]
    file = File.new(@filenames[0], 'w')
    file.puts "roly poly fish heads, eat them up yum!"
    file.close
    
    @rename = Beaver::Rename.new(RENAMEDIR)
  end
  
  def test_append
    files = @rename.append(@filenames, "_monkey")
    delete_test_files(files, "Appended file exists")
  end

  def test_prepend
    files = @rename.prepend(@filenames, "monkey_")
    delete_test_files(files, "Prepended file exists")
  end
  
  def test_both
    files = @rename.both(@filenames, "monkey_", "_monkey")
    delete_test_files(files, "A Prepended and Appended file exists")
  end
  
  def delete_test_files(files, teststatus)
    files.each do |f|
      assert(FileTest.file?(f), teststatus)
      File.unlink(f) if FileTest.file?(f)
    end
  end
 
  def test_rename_single
    files = @rename.rename(@filenames, :prepend => "monkey_")
    delete_test_files(files, "Rename single file exists")
  end
 # 
 # def test_rename_double
 #   name = "monkey_#{@filenames[0]}_monkey"
 #   @rename.rename(@filenames, :prepend => "monkey_", :append => "_monkey")
 #   assert(FileTest.file?(name), "Prepended and Appended file exists")
 #   File.unlink(name) if FileTest.file?(name)
 # end
 # 
 # def test_rename_block
 #   name = "monkey_#{@filenames[0]}"
 #   @rename.rename(@filenames) do |file|
 #     "monkey_#{file}"
 #   end
 #   assert(FileTest.file?(name), "Block modified file exists")
 #   File.unlink(name) if FileTest.file?(name)
 # end
end
