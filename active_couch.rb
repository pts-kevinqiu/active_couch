require 'optparse'
require 'httparty'
require 'json'
require 'date'

#{"pid"=>"<0.148.0>", "checkpoint_interval"=>5000, "checkpointed_source_seq"=>30, "continuous"=>true, "doc_id"=>"68c0e0a8f401d2e32ca1b85120000555", "doc_write_failures"=>0, "docs_read"=>0, "docs_written"=>0, "missing_revisions_found"=>0, "progress"=>100, "replication_id"=>"7fe5e549981919312555e29aee5caa95+continuous+create_target", "revisions_checked"=>23, "source"=>"http://admin:*****@tor-per-platformdb3.points.com:5984/_users/", "source_seq"=>30, "started_on"=>1478620814, "target"=>"http://admin:*****@localhost:5984/_users/", "type"=>"replication", "updated_on"=>1478809684}

module ActiveCouch
  class Task
    def initialize(couchdb_url, task)
      @couchdb_url = couchdb_url
      @task = task
    end

    def method_missing(key)
      key = key.to_s
      return @task[key] if @task.key?(key)
    end

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
