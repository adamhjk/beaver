require 'test/unit'
require File.dirname(__FILE__) + '/../lib/beaver'

FINDDIR = File.expand_path(File.join(File.dirname(__FILE__), 'data', 'find'))
DBFILE = File.expand_path(File.join(File.dirname(__FILE__), 'db', 'testing.sqlite'))
COMPRESSDIR = File.expand_path(File.join(File.dirname(__FILE__), 'data', 'compress'))
RENAMEDIR = File.expand_path(File.join(File.dirname(__FILE__), 'data', 'rename'))
TRANSFERDIR = File.expand_path(File.join(File.dirname(__FILE__), 'data', 'transfer'))
