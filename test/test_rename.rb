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
require 'find'

class TestRename < Test::Unit::TestCase
  
  def setup
    @filenames = [ File.join(TestHelp::RENAMEDIR, "fishheads") ]
    file = File.new(@filenames[0], 'w')
    file.puts "roly poly fish heads, eat them up yum!"
    file.close
    
    @rename = Beaver::Rename.new(TestHelp::RENAMEDIR)
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
  
  def test_rename_double
    files = @rename.rename(@filenames, :prepend => "monkey_", :append => "_monkey")
    delete_test_files(files, "Rename single file exists")
  end
  
  def test_rename_block
    files = @rename.rename(@filenames) do |file|
      "#{file}_mastodon"
    end
    delete_test_files(files, "Rename with a blog works")
  end

  def teardown
    TestHelp.delete_renamed_files
  end
end

