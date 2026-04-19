#!/usr/bin/env ruby
# Usage:
#   ./generate-vscode-settings.rb
#   ./generate-vscode-settings.rb -d   # demo mode: output to ./demo, no nvim.exe

require "optparse"
require "tmpdir"
require "fileutils"
require "readline"
require "io/console"

SCRIPT_DIR = File.dirname(File.expand_path(__FILE__))

def select_from_menu(title, items, default: 0)
  index = default

  loop do
    puts title
    items.each_with_index do |item, i|
      marker = i == index ? ">" : " "
      puts "#{marker} #{item}"
    end
    puts "Use Up/Down (or j/k) and Enter."

    key = STDIN.getch
    if key == "\e"
      next1 = STDIN.getch
      next2 = STDIN.getch
      if next1 == "[" && next2 == "A"
        index = (index - 1) % items.length
      elsif next1 == "[" && next2 == "B"
        index = (index + 1) % items.length
      end
    elsif ["\r", "\n"].include?(key)
      return index
    elsif key.downcase == "j"
      index = (index + 1) % items.length
    elsif key.downcase == "k"
      index = (index - 1) % items.length
    elsif key =~ /[1-9]/
      numeric = key.to_i - 1
      return numeric if numeric.between?(0, items.length - 1)
    end

    puts
  end
end

def prompt_output_dir
  puts(
    "This program can accept existing VSCode settings directory, in which case it will " \
    "back up the current settings and generate a new one by merging in the settings " \
    "favored by this project."
  )
  choice = select_from_menu(
    "Choose VSCode settings directory:",
    ["Temporary directory", "./", "Custom directory"]
  )

  case choice
  when 0
    Dir.mktmpdir("ansible-vscode-out.")
  when 1
    "./"
  else
    Readline.readline("Enter path: ", true)&.strip || ""
  end
end

def prompt_nvim_exe
  choice = select_from_menu(
    "Choose path to nvim.exe:",
    ["None", "scoop default", "Custom path"]
  )

  case choice
  when 0
    ""
  when 1
    user_name = Readline.readline('Enter your Windows home directory: C:\Users\ ', true)&.strip || ""
    "C:\\Users\\#{user_name}\\scoop\\shims\\nvim.exe"
  else
    Readline.readline("Enter path: ", true)&.strip || ""
  end
end

output_dir = nil
nvim_exe = nil

OptionParser.new do |opts|
  opts.banner = "Usage: #{$PROGRAM_NAME} [-d]"
  opts.on("-d", "Demo mode: output to ./demo with no nvim.exe") do
    output_dir = File.join(SCRIPT_DIR, "demo")
    nvim_exe = ""
  end
end.parse!

if output_dir.nil?
  output_dir = prompt_output_dir
  nvim_exe = prompt_nvim_exe
end

FileUtils.mkdir_p(output_dir)

extra_vars = {
  "role"                => "vscode",
  "vscode_settings_dir" => output_dir,
  "nvim_exe"            => nvim_exe,
}

system(
  "ansible-playbook",
  "--inventory", "localhost,",
  "--connection", "local",
  *extra_vars.flat_map { |k, v| ["--extra-vars", "#{k}=#{v}"] },
  File.join(SCRIPT_DIR, "playbook.yml"),
  exception: true
)
