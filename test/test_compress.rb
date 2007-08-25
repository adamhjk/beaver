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

class TestCompress < Test::Unit::TestCase
  
  def setup
    @find = Beaver::FindFile.new()
    @find.search(TestHelp::FINDDIR, :recurse => true) do |file|
      @find.add_file(file) if file =~ /foobar/
    end
    @compress = Beaver::Compress.new(TestHelp::COMPRESSDIR)
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
    compressed_files = @compress.gzip(@find.files.collect { |f| f[0] })
    compressed_files.each do |file|
      assert(FileTest.file?(file), "Compressed file exists.")
      assert(file =~ /.gz$/, "File ends in .gz")
    end
  end

  def test_compress
    compressed_files = @compress.compress(@find.files.collect { |f| f[0] }, :with => :gzip)
    compressed_files.each do |file|
      assert(FileTest.file?(file), "Compressed file exists.")
      assert(file =~ /.gz$/, "File ends in .gz")
    end
  end
  
  def teardown
    TestHelp.delete_compressed_files
  end
  
end

