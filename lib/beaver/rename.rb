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
  
  # Renames files
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
    
    # Append "with" to the end of the filename.
    def append(files, with)
      munge_files(files) { |f| "#{f}#{with}" }
      @files
    end
    
    # Prepend "with" to the beginning of the filename
    def prepend(files, with)
      munge_files(files) { |f| "#{with}#{f}" }
      @files
    end
    
    # Prepend "prepend" and append "append" to the filename
    def both(files, prepend, append)
      munge_files(files) { |f| "#{prepend}#{f}#{append}" }
      @files
    end
    
    # A convenience method around append and append.  You can provide
    # :prepend => value and :append => value, and rename will do the right
    # thing.  Additionally, you can skip all of that and just provide your
    # own block, which should take a filename as an argument and return
    # the new name you want it to have.
    #
    # Example:
    # 
    #     rename.rename(files) do |file|
    #       "#{file}_monkey_#{file}"
    #     end
    #
    # Would make a very nonsensical filename. :)
    def rename(files, args=nil, &block)
      if block
        munge_files(files, &block)
      elsif args
        if args[:prepend] && args[:append]
          both(files, args[:prepend], args[:append])
        elsif args[:prepend]
          prepend(files, args[:prepend])
        elsif args[:append]
          append(files, args[:append])
        else
          raise ArgumentException, "You must supply :append, :prepend, or both"
        end
      end
      @files
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