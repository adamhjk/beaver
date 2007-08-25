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

module Beaver
  #
  # Compresses a set of files with the given compression mechanism.
  #
  class Compress    
    attr_reader :compress_dir
    attr_accessor :files
   
    # Creates a new Beaver::Compress object.  Requires a directory for the
    # resulting compressed files.
    def initialize(dir)
      raise ArgumentError, "Directory #{dir} must exist!" unless FileTest.directory?(dir)
      @compress_dir = dir
      @files = Array.new
    end

    # Takes a list of files, an optional argument list, and possibly a block.
    # If given just a list of files, it will gzip them.  If args[:with]
    # matches a method name in this class, it will use that to compress the 
    # files.  If given a block, it simply yields each file to the block.
    def compress(files, args=nil, &block)
      if block
        block.call(files)
      elsif args && args[:with]
        files.each do |f|
          self.method(args[:with]).call(f)
        end
      else
        gzip(files)
      end
      @files
    end
    
    # Gzips the list of files.
    def gzip(files)
      cmd = `which gzip`.chomp!
      # FIXME:  This might suck, if you have files with the same basename in multiple subdirectories.
      files.each do |f|
        compress_file_name = File.join(@compress_dir, "#{File.basename(f)}.gz")
        output = `#{cmd} -c #{f} > #{compress_file_name}`
        if output == false
          raise RuntimeError, "Cannot compress, gzip error #{$?}: #{output}"
        end
        @files << compress_file_name
      end
      @files
    end
    
  end
end