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

class TestFind < Test::Unit::TestCase
  
  def setup
    @find = Beaver::FindFile.new()
  end

  def test_find
    file_list = Array.new
    @find.search(TestHelp::FINDDIR, :recurse => true) do |file|
      file_list << file
      @find.add_file(file) if file =~ /foobar/
    end
    check_files(file_list)
  end
  
  def test_find_datetime
    file_list = Array.new
    @find.search(TestHelp::FINDDIR, :recurse => true) do |file|
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

