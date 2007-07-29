require 'test/unit'
require File.dirname(__FILE__) + '/../lib/beaver'

DATADIR       = File.expand_path(File.join(File.dirname(__FILE__), 'data'))
FINDDIR       = File.expand_path(File.join(File.dirname(__FILE__), 'data', 'find'))
FINDFILE      = File.expand_path(File.join(File.dirname(__FILE__), 'data', 'find', 'foobar_production.log'))
DBFILE        = File.expand_path(File.join(File.dirname(__FILE__), 'db', 'testing.sqlite'))
COMPRESSDIR   = File.expand_path(File.join(File.dirname(__FILE__), 'data', 'compress'))
RENAMEDIR     = File.expand_path(File.join(File.dirname(__FILE__), 'data', 'rename'))
TRANSFERDIR   = File.expand_path(File.join(File.dirname(__FILE__), 'data', 'transfer'))
TRANSFER_FILE = File.join(TRANSFERDIR, "transfer_file")
TO_FILE       = File.join(TRANSFERDIR, "new_transfer_file")
LANDING       = File.join(TRANSFERDIR, "landing")
LANDING_FILE  = File.join(LANDING, "transfer_file")
DELETEDIR     = File.expand_path(File.join(File.dirname(__FILE__), 'data', 'delete'))
BEAVERSCRIPT  = File.expand_path(File.join(File.dirname(__FILE__), 'data', 'test.beaver'))


class TestHelp
  def self.establish_ar
    ActiveRecord::Base.establish_connection(
      :adapter => 'sqlite3',
      :database => DBFILE
    ) 
    ActiveRecord::Base.logger = Logger.new(File.open('../logs/database.log', 'a'))  

    ActiveRecord::Migrator.migrate(
      File.join(File.dirname(__FILE__), '..', 'db', 'migrate'),
      nil  
    )
  end
  
  def self.teardown_ar
    File.unlink(DBFILE)
  end
  
  def self.delete_compressed_files
    Find.find(COMPRESSDIR) do |file|
      File.unlink(file) if file =~ /\.gz$/
    end
  end
  
  def self.delete_renamed_files
    Find.find(RENAMEDIR) do |file|
      File.unlink(file) if FileTest.file?(file)
    end
  end
  
  def self.if_live_tests(&block)
    if ENV["LIVE_USER"] && ENV["LIVE_HOST"] && ENV["LIVE_KEY"]
      block.call
    end
  end
  
end

