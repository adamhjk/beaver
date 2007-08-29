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
  
  # Transfers files
  class Transfer    
    attr_accessor :files
   
    SSH_OPTIONS = "-o StrictHostKeyChecking=no -o ChallengeResponseAuthentication=no -o CheckHostIP=no -o HostbasedAuthentication=no -o PasswordAuthentication=no -o PreferredAuthentications=publickey"
   
    def initialize
      @files = Array.new
      @rsync = `which rsync`.chomp!
      @ssh = `which ssh`.chomp!
      @scp = `which scp`.chomp!
      @cp = `which cp`.chomp!
    end
    
    # Takes a list of files to transfer, and a set of arguments.  Requires
    # :with => (:scp | :rsync), :user, :host, :to, :ssh_key.
    def transfer(files, args)
      raise ArgumentException, "Must have :with as an argument!" unless args && args[:with]
      
      transfer_method = self.method(args[:with])
      output = String.new
      # FIXME: If we have more than one file, we should concat things for
      #        the rsync provider.
      files.each do |file|
        output << transfer_method.call(file, args[:user], args[:host], args[:to], args[:ssh_key])
      end
      output
    end
    
    # Rsync a file to a remote path.
    def rsync(file, user, host, rpath, key)
      run_command("#{@rsync} -a -e '#{@ssh} #{SSH_OPTIONS} -i #{key}' #{file} #{user}@#{host}:#{rpath} 2>&1")
    end
    
    # scp a file to a remote path.
    def scp(file, user, host, rpath, key)
      run_command("#{@scp} #{SSH_OPTIONS} -i '#{key}' #{file} #{user}@#{host}:#{rpath} 2>&1")
    end
    
    # Run an ssh command on a remote host.
    def ssh(user, host, cmd, key)
      run_command("#{@ssh} #{SSH_OPTIONS} -i '#{key}' #{user}@#{host} '#{cmd}' 2>&1")
    end
    
    # Copy files with cp
    def cp(file, user, host, rpath, key)
      run_command("#{@cp} #{file} #{rpath}")
    end
    
    private
    
      def run_command(command)
        pipe = IO.popen("#{command}")
        output = String.new
        while (line = pipe.gets)
          output << line
        end
        pipe.close
        if ! $?.success?
          raise RuntimeError, "Cannot execute: #{command} exited #{$?.exitstatus}: #{output}"
        end
        output
      end
    
  end
end