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

require 'logger'
require 'date'

module Beaver
  
  # Encapsulates a particular Log job.  Handles finding, compressing, 
  # renaming, transferring, and deleting files.  
  class Job
    attr_reader :files
    
    # Creates a new Beaver::Job object.  
    def initialize(config=nil)  
      @variables = Hash.new
      @find = Beaver::FindFile.new
      @files = Array.new
      @logger = Logger.new(STDOUT)
      @logger.sev_threshold = Logger::ERROR
      set_from_config(config) if config 
      @logger.debug("Initialized Job")
    end
    
    # Sets a configuration value.  Common keys are:
    #
    #   set :source => "unit test"
    #   set :compress_directory => COMPRESSDIR
    #   set :rename_directory => RENAMEDIR
    #   set :transfer_user => ENV["LIVE_USER"]
    #   set :transfer_host => ENV["LIVE_HOST"]
    #   set :transfer_ssh_key  => ENV["LIVE_KEY"]
    #   set :transfer_to => "/tmp"
    #
    # The job will fail if some of these values aren't set.  The :source,
    # :compress_directory and :rename_directory values are required for any
    # job to execute.  The :transfer_ keys can be specified when calling
    # transfer as well, which will override these defaults.
    def set(values)
      values.each do |k, v|
        @logger.debug("Set value #{k} to #{v}")
        @variables[k] = v
      end
      true
    end
    
    # Get a configuration value.
    def get(key)
      @variables.has_key?(key) ? @variables[key] : nil 
    end
    
    # Ensure that all the variables this job needs are set.  Example:
    #
    #    want(:binlog_dir, :transfer_host)
    #
    # Would make sure that both binlog_dir and transfer_host are set.
    def want(*values)
      values.each do |v|
        unless @variables.has_key?(v)
          raise ArgumentError, "This job requires #{v.to_s} to be set."
        end
      end
    end
    
    # Find files underneath a directory.  Requires a block, which will be
    # passed each file.  Should call add_file(file) for any files that should
    # be included in this job.
    #
    # Example:
    # 
    #     find("/tmp") { |f| add_file(f) if FileTest.file?(f) }
    #
    # Would add all the files under /tmp to this job.
    def find(dir, args=nil, &block)
      job_configured?
      @logger.debug("Finding files")
      @find.search(dir, args, &block)
      raise ArgumentError, "No files added in your find." unless have_files?
    end
    
    # Add's a file to this job.  Takes a filename and an optional date.  See
    # Beaver::FindFile::add_file for more information on how the datetime
    # logic works.
    def add_file(file, datetime=nil)
      job_configured?
      nfile, ndatetime, shasum = @find.add_file(file, datetime)
      @logger.debug("Added file #{nfile} at #{ndatetime} with shasum #{shasum}")
      log_file = Beaver::DB::Log.find(:first, :conditions => { :name => nfile, :shasum => shasum })
      unless log_file
        log_file = Beaver::DB::Log.new(
          :name => nfile,
          :currentfile => nfile,
          :logdate => ndatetime,
          :shasum => shasum,
          :source => get(:source),
          :status => "found"
        )
        log_file.save
      end
      @files << log_file unless log_file.status == 'waiting'
      log_file
    end
    
    # Compresses the files found by calling find and add_file.  If you pass
    # a block, you are expected to do something that results in your files
    # winding up in the :compress_directory.  
    def compress(args, &block)
      job_configured?
      @logger.debug("Compressing files")
      raise ArgumentError, "You must have some files to compress; perhaps you need to run find first?" unless have_files?
      compress = Beaver::Compress.new(get(:compress_directory))
      compress.compress(current_files(), args, &block)
      update_current_files(compress.files, "compressed")
    end
        
    # Renames the files found by calling find and add_file (or compress)
    # Be careful about calling rename without an interim compress block,
    # because you'll rename the original file (essentially deleting it.) 
    def rename(args=nil, &block)
      job_configured?
      @logger.debug("Renaming files")
      raise ArgumentError, "You must have some files to rename; perhaps you need to run find first?" unless have_files?
      rename = Beaver::Rename.new(get(:rename_directory))
      rename.rename(current_files(), args, &block)
      update_current_files(rename.files, "renamed")
    end
    
    # Deletes the files in this job.  Has an optional argument, :keep, which
    # takes the number of files you want to keep on disk.  It decides which
    # to keep by sorting them by date and time, counting backwards from the
    # latest. (ie: the last 10 updated files for :keep => 10)
    def delete(args=nil, &block)
      job_configured?
      @logger.debug("Deleting files")
      raise ArgumentError, "You must have some files to delete; perhaps you need to run find first?" unless have_files?
      if block
        @files.each do |file|
          result = block.call(file.currentfile)
          if result == false
            file.status = "waiting"
            file.save
          else
            file.destroy
          end
        end
      elsif args
        raise ArgumentError, "You must have :keep as an argument" unless args[:keep]
        logs = Beaver::DB::Log.find(:all, :conditions => [ "source = ?", get(:source) ], :order => "logdate DESC")
        count = 1
        logs.each do |log|
          if count <= args[:keep]
            @logger.debug("Saving #{log.name} and #{log.currentfile}")
            log.status = "waiting"
            log.save
          else
            @logger.debug("Deleting #{log.name} and #{log.currentfile}")
            delete_log(log)
          end
          count += 1
        end
      else
        logs = Beaver::DB::Log.find(:all)
        logs.each do |log|
          delete_log(log)
        end
      end
    end
    
    # Transfers a file, or runs a command on a remote host.  See 
    # Beaver::Transfer for a list of possible backends.  Takes options
    # such as:
    #      :with    - The backend to use.
    #      :user    - The user to log in with, if using scp or rsync
    #      :host    - The host to transfer to
    #      :to      - The directory on that host to put the files
    #      :ssh_key - The ssh key to use, if scp or rsync
    #      :mkdir   - Whether to ensure the remote directory exists,
    #                 defaults to true.
    def transfer(args=nil, &block)
      job_configured?
      @logger.debug("Transferring files")
      transfer = Beaver::Transfer.new
      raise ArgumentError, "You must have some files to transfer; perhaps you need to run find first?" unless have_files?
      if block
        @files.each do |file|
          block.call(file.currentfile)
          update_status("transferred")
        end
      elsif args
        missing = Array.new
        args[:user]    ||= get(:transfer_user)
        args[:host]    ||= get(:transfer_host)
        args[:to]      ||= get(:transfer_to)
        if get(:append_source)
          args[:to] = File.join(args[:to], get(:source))
        end
        if get(:append_hostname)
          args[:to] = File.join(args[:to], `hostname`.chomp!)
        end
        if get(:append_transfer_date)
          args[:to] = File.join(args[:to], transfer_date())
        end
        args[:ssh_key] ||= get(:transfer_ssh_key)
        args[:mkdir]   ||= true
        args[:with]    ||= nil
        if args[:with] == :ssh
          unless args[:cmd] && args[:host] && args[:user] && args[:ssh_key]
            raise ArgumentError, "You must specify :cmd, :host, :user and :ssh_key for the ssh command."
          end
          transfer.ssh(args[:user], args[:host], args[:cmd], args[:ssh_key])
        else
          unless args[:user] && args[:host] && args[:to] && args[:ssh_key] && args[:mkdir] && args[:with]
            missing = Array.new
            args[:user]
            raise ArgumentError, "You must specify :user, :host, :to, and :ssh_key, or have them set with 'set :transfer_foo => bar' globally."
          end
          transfer.ssh(args[:user], args[:host], "mkdir -p #{args[:to]}", args[:ssh_key]) if args[:mkdir]
          transfer.transfer(@files.collect { |f| f.currentfile }, args)
          update_status("transferred")
        end
      else
        raise ArgumentError, "You must pass arguments or a block, but you can't omit both."
      end
    end
    
    # Load's a script for this job.  It is executed in the context of this
    # instance.  
    def load(scriptfile)
      eval(IO.read(scriptfile))
    end
    
    def cleanup
      logs = Beaver::DB::Log.find(:all, :conditions => [ "source = ? and status != ?", get(:source), "waiting" ])
      logs.each do |file|
        puts file.status
        file.destroy unless file.status == "waiting"
      end
    end
    
    def transfer_date
      now = DateTime.now
      now.strftime("%Y%m%d")
    end
    
    private
      
      def set_from_config(config)
        set(:compress_directory => config.compress_directory)
        set(:rename_directory => config.rename_directory)
        set(:transfer_user => config.transfer_user)
        set(:transfer_host => config.transfer_host)
        set(:transfer_ssh_key => config.transfer_ssh_key)
        set(:transfer_to => config.transfer_to)
        set(:append_source => config.append_source)
        set(:append_hostname => config.append_hostname)
        set(:append_transfer_date => config.append_transfer_date)
        if config.log_level
          case config.log_level
          when "DEBUG"
            @logger.sev_threshold = Logger::DEBUG
          when "INFO"
            @logger.sev_threshold = Logger::INFO
          when "WARN"
            @logger.sev_threshold = Logger::WARN
          when "ERROR"
            @logger.sev_threshold = Logger::ERROR
          when "FATAL"
            @logger.sev_threshold = Logger::FATAL
          when "UNKNOWN"
            @logger.sev_threshold = Logger::UNKNOWN
          end
        end
      end
    
      def delete_log(log)
        deleteobj = Beaver::Delete.new
        deleteobj.delete_file(log.name)
        deleteobj.delete_file(log.currentfile)
        log.destroy
        true
      end
    
      def update_status(status)
        @files.each do |file|
          file.status = status
          file.save
        end
        true
      end
    
      def update_current_files(new_files, status)
        new_files.each_index do |x|
          @files[x].currentfile = new_files[x]
          @files[x].status = status
          @files[x].save
        end
      end
    
      def job_configured?
        missing = Array.new
        if ! get(:source)
          missing << :source
        elsif ! get(:compress_directory)
          missing << :compress_directory
        elsif ! get(:rename_directory)
          missing << :rename_directory
        end
        if missing.length > 0
          raise ArgumentError, "You must specify set the following values for this job: #{missing.join(', ')}!"
        end
      end
      
      def have_files?
        files.length > 0
      end
      
      def current_files
        @files.collect { |f| f.currentfile }
      end
    
  end
end