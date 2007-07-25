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

module Beaver
  #
  # Renames files
  #
  class Rename    
    attr_reader :rename_dir
    attr_accessor :files
   
    # Creates a new Beaver::Rename object.  Requires a directory for the
    # resulting renamed files.
    def initialize(dir)
      raise ArgumentError, "Directory #{dir} must exist!" unless FileTest.directory?(dir)
      @rename_dir = dir
      @files = Array.new
    end

    def rename(files, args=nil, &block)
      @files
    end
    
    def append(files, with)
      munge_files(files) { |f| "#{f}#{with}" }
      @files
    end
    
    def prepend(files, with)
      munge_files(files) { |f| "#{with}#{f}" }
      @files
    end
    
    def both(files, prepend, append)
      munge_files(files) { |f| "#{prepend}#{f}#{append}" }
      @files
    end
    
    def rename(files, args, &block)
      if block
        munge_files(files, block)
      end
    end
    
    private
    
      def munge_files(files, &block)
        files.each do |f|
          filename = File.basename(f)
          new_filename = File.join(@rename_dir, block.call(filename))
          File.rename(f, new_filename)
          @files << new_filename
        end
      end
    
  end
end