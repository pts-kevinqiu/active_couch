require 'optparse'
require 'httparty'
require 'json'
require 'date'

module ActiveCouch
  def create_task(couchdb_url, task)
    ReplicationTask.new(couchdb_url, task)
  end

  class Task
    def initialize(couchdb_url, task)
      @couchdb_url = couchdb_url
      @task = task
    end

    def method_missing(key)
      key = key.to_s
      return @task[key] if @task.key?(key)
    end
  end

  class ReplicationTask < Task
  end

  class IndexingTask < Task
    def name
      "#{@couchdb_url} - #{database}:#{design_document}"
    end

    def rate
      (1.0 * changes_done / (updated_on - started_on)).round(2)
    end

    def eta
      {
        time: started_on + (total_changes / rate),
        relative: (total_changes - changes_done) / rate
      }
    end
  end

  def self.get_tasks(couch_hosts)
    tasks = []
    couch_hosts.each { |host|
      response = HTTParty.get("#{host}/_active_tasks")
      json_response = JSON.parse(response.body)
      tasks += json_response.collect { |task| Task.new(host, task) }
    }
    tasks
  end
end

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