#! /usr/bin/ruby

require 'active_couch'

def main(couchdb_urls)
  tasks = ActiveCouch::get_tasks couchdb_urls

  def render_eta(eta)
    absolute_time = DateTime.strptime(eta[:time].to_s, "%s")
    relative_hours = (eta[:relative] / 3600).floor
    relative_minutes = ((eta[:relative] - (relative_hours * 3600)) / 60).floor
    "#{absolute_time} (in #{relative_hours} hours #{relative_minutes} minutes)"
  end

  def render_progress_bar(done, total, bar_length=40)
    completed = ((1.0 * done / total) * bar_length).floor
    remaining = bar_length - completed
    "[#{"#" * completed}#{"_" * remaining}] (#{(100.0*done/total).round(2)}%)"
  end

  tasks.each { |task|
    puts "#{task.name}"
    puts "  progress: #{render_progress_bar(task.changes_done, task.total_changes)}"
    puts "  rate: #{task.rate} cps (changes-per-second)"
    puts "  eta: #{render_eta(task.eta)}"
    puts
  }

  return 0
end

if ARGV.length == 0
  puts 'Usage: active_couch.rb <couchdb_urls...>'
  puts 'Example: ruby active_couch.rb http://admin:password@localhost:5984 http://admin:password@yourdomain.com:5984'
  exit 1
end

exit main(ARGV)
