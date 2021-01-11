require 'yaml'
FILE_PATH = "./.program_pid_list.yml"

def activate_program(program_name, program_command)
  program_pid = find_if_open program_name
  if program_pid
    bring_to_top program_pid
  else
    program_pid = execute program_command
    store_pid program_name, program_pid
  end
end

def find_if_open(program_name)
  program_pid = find_in_file program_name
  return nil unless program_pid
  is_active = verify_active program_pid
  puts is_active
  if is_active then program_pid else nil end
end

def verify_active(program_pid)
  system("ps -p #{program_pid}")
end

def find_in_file(program_name)
  if File.exist? FILE_PATH
    file = File.read(FILE_PATH)
    yml = YAML.load(File.read FILE_PATH)
    yml[program_name]
  else
    nil
  end
end

def store_pid(program_name, program_pid)
  if File.exist? FILE_PATH
    file = File.read(FILE_PATH)
    yml = YAML.load(File.read FILE_PATH)
  else
    yml = {}
  end
  yml[program_name] = program_pid
  File.write(FILE_PATH, yml.to_yaml)
end

def bring_to_top(program_pid)
  r = `wmctrl -lp | awk '$3==#{program_pid} {print $1; exit}'`.chomp
  `wmctrl -ia #{r}`
end

def execute(program_command)
  `#{program_command} > /dev/null & echo $!`.chomp
end

activate_program ARGV[0], ARGV[1]
