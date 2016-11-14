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

  def self.create_task(couchdb_url, task)
    IndexingTask.new(couchdb_url, task)
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
