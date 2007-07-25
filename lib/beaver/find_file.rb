# Author:: Adam Jacob (<adam@hjksolutions.com>)
# Copyright:: Copyright (c) 2007 HJK Solutions, LLC
# License:: GNU General Public License version 2.1
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 
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

require 'find'

module Beaver
  
  # Finds files according to a block
  class FindFile    
    attr_accessor :files
    
    def initialize
      @files = Array.new
    end
    
    # Add a new file to the list of files that match.  De-dupes.
    def add_file(file)
      @files << file unless @files.detect { |f| f == file }
    end
    
    # Takes a directory to search and a block.  Each file gets yielded to the
    # block.  Ideally, the block will call add_file if the file matches.  
    def search(dir, args=nil, &block)
      files = Array.new
      Find.find(dir) do |path|
        file = block.call(path) if FileTest.file?(path)
        files << file if file != nil
      end
    end
  end
end