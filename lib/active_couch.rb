require 'optparse'
require 'httparty'
require 'json'
require 'date'

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

    def render
      "#{name}"
    end
  end

  class ReplicationTask < Task
    def name
      "Replication : #{@couchdb_url} - #{replication_id}"
    end
  end

  class CompactionTask < Task
    def name
      "Compaction: #{@couchdb_url}"
    end
  end

  class IndexingTask < Task
    def name
      "Indexing: #{@couchdb_url} - #{database}:#{design_document}"
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

    def render
      ["#{name}",
       "  progress: #{render_progress_bar(changes_done, total_changes)}",
       "  rate: #{rate} cps (changes-per-second)",
       "  eta: #{render_eta(eta)}",
      ].join("\n")
    end
  end

  def self.create_task(couchdb_url, task)
    puts task
    if task['type'] == 'replication'
      ReplicationTask.new(couchdb_url, task)
    elsif task['type'] == 'view_compaction'
      CompactionTask.new(couchdb_url, task)
    else
      IndexingTask.new(couchdb_url, task)
    end
  end

  def self.get_tasks(couch_hosts)
    tasks = []
    couch_hosts.each { |host|
      response = HTTParty.get("#{host}/_active_tasks")
      json_response = JSON.parse(response.body)
      tasks += json_response.collect { |task| create_task(host, task) }
    }
    tasks
  end
end
