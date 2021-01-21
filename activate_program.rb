#! /bin/ruby

require 'yaml'
FILE_PATH = "#{File.expand_path(File.dirname(__FILE__))}/.program_wid_list.yml"

def activate_program(program_name, program_command)
  program_wid = get_wid_if_open program_name
  if program_wid
    bring_to_top program_wid
  else
    program_wid = execute program_command
    store_wid program_name, program_wid
  end
end

def get_wid_if_open(program_name)
  program_wid = retrieve_wid_from_file program_name
  return nil unless exists? program_wid
  program_wid
end

def exists?(program_wid)
  return unless program_wid
  wid_exists = `wmctrl -l | awk '$1==\"#{program_wid}\" {print \"true\"}'`.chomp
  wid_exists == 'true'
end

def retrieve_wid_from_file(program_name)
  if File.exist? FILE_PATH
    yml = YAML.load(File.read FILE_PATH)
    yml[program_name]
  else
    nil
  end
end

def store_wid(program_name, program_wid)
  if File.exist? FILE_PATH
    file = File.read(FILE_PATH)
    yml = YAML.load(File.read FILE_PATH)
  else
    yml = {}
  end
  yml[program_name] = program_wid
  File.write(FILE_PATH, yml.to_yaml)
end

def bring_to_top(program_wid)
  `wmctrl -ia #{program_wid}`
end

def execute(program_command)
  `#{program_command} > /dev/null`.chomp
  # assume last window is wid
  `wmctrl -l | awk '{print $1}'`.split("\n").last
end

activate_program ARGV[0], ARGV[1]
