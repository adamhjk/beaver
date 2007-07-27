module Beaver
  class Job
    attr_reader :files
    
    def initialize()  
      @variables = Hash.new
      @find = Beaver::FindFile.new
      @files = Array.new
    end
    
    def set(values)
      values.each do |k, v|
        @variables[k] = v
      end
      true
    end
    
    def get(key)
      @variables.has_key?(key) ? @variables[key] : nil 
    end
    
    def find(dir, args=nil, &block)
      job_configured?
      @find.search(dir, args, &block)
      raise ArgumentError, "No files added in your find." unless have_files?
    end
    
    def add_file(file, datetime=nil)
      job_configured?
      nfile, ndatetime, shasum = @find.add_file(file, datetime)
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
    
    def compress(args, &block)
      job_configured?
      raise ArgumentError, "You must have some files to compress; perhaps you need to run find first?" unless have_files?
      compress = Beaver::Compress.new(get(:compress_directory))
      compress.compress(current_files(), args, &block)
      update_current_files(compress.files, "compressed")
    end
    
    # FIXME: What happens if you rename from find?  You'll de-facto delete.
    def rename(args=nil, &block)
      job_configured?
      raise ArgumentError, "You must have some files to rename; perhaps you need to run find first?" unless have_files?
      rename = Beaver::Rename.new(get(:rename_directory))
      rename.rename(current_files(), args, &block)
      update_current_files(rename.files, "renamed")
    end
    
    def delete(args=nil, &block)
      job_configured?
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
        
      else
        
      end
    end
    
    def transfer(args=nil, &block)
      job_configured?
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
    
    private
    
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