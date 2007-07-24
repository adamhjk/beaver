require File.dirname(__FILE__) + '/test_helper.rb'

class TestDB < Test::Unit::TestCase
  DBFILE = File.join(File.dirname(__FILE__), 'db', 'testing.sqlite')  
  
  def setup
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
  
  def test_db_log
    log = Beaver::DB::Log.new(
      :name => 'fake',
      :shasum => '4e98e2e06bd6006f27fafe30af5ec13a59ad470e',
      :source => 'unit test',
      :status => 'transferring'
    )
    assert(log.save, "Created a new log")
    fake_log = Beaver::DB::Log.find_by_name('fake')
    assert(fake_log, "Log can be found by name")
    assert(fake_log.name == 'fake', "Log has correct name")
  end
  
  def teardown
    File.unlink(DBFILE)
  end
end
