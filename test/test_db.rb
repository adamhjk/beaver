require File.dirname(__FILE__) + '/test_helper.rb'

class TestDB < Test::Unit::TestCase
  
  def setup
    TestHelp.establish_ar
  end
  
  def test_db_log
    log = Beaver::DB::Log.new(
      :name => 'fake',
      :shasum => '4e98e2e06bd6006f27fafe30af5ec13a59ad470e',
      :source => 'unit test',
      :status => 'transferring',
      :logdate => Time.now
    )
    assert(log.save, "Created a new log")
    fake_log = Beaver::DB::Log.find_by_name('fake')
    assert(fake_log, "Log can be found by name")
    assert(fake_log.name == 'fake', "Log has correct name")
  end
  
  def teardown
    TestHelp.teardown_ar
  end
end
