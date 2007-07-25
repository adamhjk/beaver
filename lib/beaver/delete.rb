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
  
  # Deletes files
  class Delete    
    attr_accessor :files
   
    # Creates a new Beaver::Rename object.  Requires a directory for the
    # resulting renamed files.
    def initialize(dir)
      @files = Array.new
    end
    
    # Append "with" to the end of the filename.
    def delete(file)
      File.unlink(file) if FileTest.file?(file)
    end
    
  end
end