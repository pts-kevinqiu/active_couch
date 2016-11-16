#! /usr/bin/ruby

require 'active_couch'

def main(couchdb_urls)
  tasks = ActiveCouch::get_tasks couchdb_urls

  tasks.each { |task|
    puts task.render
  }

  return 0
end

if ARGV.length == 0
  puts 'Usage: active_couch.rb <couchdb_urls...>'
  puts 'Example: ruby active_couch.rb http://admin:password@localhost:5984 http://admin:password@yourdomain.com:5984'
  exit 1
end

exit main(ARGV)
