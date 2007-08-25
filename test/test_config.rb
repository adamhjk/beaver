require File.dirname(__FILE__) + '/test_helper.rb'

class TestRename < Test::Unit::TestCase
  
  def test_no_config
    config = Beaver::Config.new()
    assert_kind_of(Beaver::Config, config)
    assert_equal(config.compress_directory, '/var/lib/beaver/compress')
    assert_equal(config.rename_directory, '/var/lib/beaver/rename')
    assert_equal(config.db, { 
      "adapter"  => 'sqlite3', 
      "database" => '/var/lib/beaver/beaver.db', 
    })
    assert_nil(config.transfer_user)
    assert_nil(config.transfer_host)
    assert_nil(config.transfer_ssh_key)
  end
  
  def test_config_from_file
    config = Beaver::Config.new(CONFIGFILE)
    assert_kind_of(Beaver::Config, config)
    assert_equal(config.compress_directory, '/tmp/compress')
    assert_equal(config.rename_directory, '/tmp/rename')
    assert_equal(config.db, {
      "adapter"  => 'sqlite3',
      "database" => 'db/beaver.sqlite'
    })
    assert_equal(config.transfer_user, 'adam')
    assert_equal(config.transfer_host, 'localhost')
    assert_equal(config.transfer_ssh_key, 'ssh_key.id')
  end
  
  def setup_database
    config = Beaver::Config.new()
    config.db = {
      "adapter" => 'sqlite3',
      "database" => DBFILE
    }
    config.setup_database
  end

end

