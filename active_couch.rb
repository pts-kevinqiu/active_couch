require 'httparty'
require 'json'
require 'date'

module ActiveCouch
  class Task
    def initialize(task)
      @task = task
    end

    def method_missing(key)
      key = key.to_s
      return @task[key] if @task.key?(key)
    end

    def name
      "#{database}:#{design_document}"
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
      tasks += json_response.collect { |task| Task.new(task) }
    }
    tasks
  end
end

tasks = ActiveCouch::get_tasks ['http://admin:password@localhost:15984', 'http://admin:password@localhost:25984']

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
