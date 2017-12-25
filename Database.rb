require 'rubygems'
require 'sqlite3'

db = SQLite::Database.new( "test.db" )
rows = db.execute( "select * from test" )
