require 'togglv8'
require 'json'
require 'forwardable'

class TogglWrapper
  attr_accessor :api_key, :toggl
  extend Forwardable
  def_delegators :@toggl, :get_current_time_entry, :stop_time_entry, :start_time_entry

  def initialize(file)
    @api_key = load_config(file)
    @toggl = TogglV8::API.new(@api_key)
  end

  def load_config(file)
    JSON.parse(File.read(file))["toggl"]
  end

  def shotgun_workspace_id
    @shotgun_workspace_id ||= toggl.workspaces.to_a.find{|w| w["name"] == "Shotgun"}["id"]
  end

  def projects
    @projects ||= toggl.projects(shotgun_workspace_id)
  end

  def find_project_by_number(id)
    projects.find {|p| p["name"] =~ /^#?#{id}/} || raise("No project with id: #{id}")
  end
  
  def current_task
    @current_task ||= toggl.get_current_time_entry
  end

  def last_task
    @last_task ||= toggl.get_time_entries.sort_by{|te| te["stop"]}.last
  end
end


class TogglAction
  attr_accessor :toggl_wrapper

  def initialize(toggl_wrapper)
    @toggl_wrapper = toggl_wrapper
  end

  def start_new_task(project_number, message)
    project = toggl_wrapper.find_project_by_number(project_number)
    toggl_wrapper.start_time_entry({'pid' => project["id"], description: message})
    p "New task on '#{project["name"]}: #{message}' started"
  end

  def restart_previous_task
    unless toggl_wrapper.current_task

      project = toggl_wrapper.projects.find{|p| p["id"] == toggl_wrapper.last_task["pid"]}["name"]
      toggl_wrapper.start_time_entry({'pid' => toggl_wrapper.last_task["pid"], description: toggl_wrapper.last_task["description"]})     
      p "Previous task on '##{project}' restarted"
    else
      p "A task is currently running"
    end
  end

  def stop_task
    if toggl_wrapper.current_task
      toggl_wrapper.stop_time_entry(toggl_wrapper.current_task["id"])     
      p "Task stopped"
    else
      p "No task running"
    end
  end

end

class LineParser
  def initialize(args)
    @line = args.join(" ")
  end

  def start?
    @line =~ /^start/
  end

  def restart?
    @line =~ /^restart/
  end

  def stop?
    @line =~ /^stop/
  end

  def ticket_number
    @line =~ /start\s*#?(\d+)/
    $1
  end

  def message
    @line =~ /start\s*#?\d+\s(.*)$/
    $1
  end
end

lp = LineParser.new(ARGV)
tw = TogglWrapper.new("#{ENV['HOME']}/.toggl2shotgun")
toggl = TogglAction.new(tw)
toggl.start_new_task(lp.ticket_number, lp.message) if lp.start?
toggl.restart_previous_task if lp.restart?
toggl.stop_task if lp.stop?
