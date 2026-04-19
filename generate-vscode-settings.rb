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

def value(if_demo = nil, &block)
  proc do
    return if_demo if demo_mode && !if_demo.nil?
    block.call
  end
end

def ask_user(title, items, default: 0)
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
      return items[index]
    elsif key.downcase == "j"
      index = (index + 1) % items.length
    elsif key.downcase == "k"
      index = (index - 1) % items.length
    elsif key =~ /[1-9]/
      numeric = key.to_i - 1
      return items[numeric]
    end

    puts
  end
end


demo_mode = false

OptionParser.new do |opts|
  opts.banner = "Usage: #{$PROGRAM_NAME} [-d]"
  opts.on("-d", "Demo mode: output to ./demo with no nvim.exe") do
    demo_mode  = true
  end
end.parse!

# Ansible roles
roles = {
    # Role in dsakurai.common
    "vscode" => {
        # A variable in Ansible we pass to the playbook
        "vscode_settings_dir" =>
        (demo_mode ? -> { File.join(SCRIPT_DIR, "demo") } # Value used in demo mode. Note that, this is a lambda function that will return the demo value when called.
                   : -> do # When we are not in the demo mode, ask the user for what value to set.
                        puts "..."
                        choice = ask_user("Choose VSCode settings directory:", ["Temporary directory", "./", "Custom directory"])
                        case choice
                        when "Temporary directory"
                          Dir.mktmpdir("ansible-vscode-out.")
                        when "./"
                          "./"
                        else
                          Readline.readline("Enter path: ", true)&.strip || ""
                        end
                   end
        ),

        "nvim_exe" =>
        (demo_mode ? -> {""}
                   : -> do
                        choice = ask_user(
                          "Choose path to nvim.exe:",
                          ["None", "scoop default", "Custom path"]
                        )

                        case choice
                        when "None"
                          ""
                        when "scoop default"
                          user_name = Readline.readline('Enter your Windows home directory: C:\Users\ ', true)&.strip || ""
                          "C:\\Users\\#{user_name}\\scoop\\shims\\nvim.exe"
                        else
                          Readline.readline("Enter path: ", true)&.strip || ""
                        end
                end
        ),
    }
}

if demo_mode

    # Run all roles found in `roles`
    roles_selected = [
        roles.keys
    ]

else
    roles_selected = [
        ask_user("Choose role:", roles.keys)
    ]
end

roles_selected.each do |role|

  extra_vars = { "role" => role }.merge(
    roles[role].transform_values(&:call)
  )

  puts "Extra-vars passed to Ansible: #{extra_vars.inspect}"

  system(
    "ansible-playbook",
    "--inventory", "localhost,",
    "--connection", "local",
    *extra_vars.flat_map { |k, v| ["--extra-vars", "#{k}=#{v}"] },
    File.join(SCRIPT_DIR, "playbook.yml"),
    exception: true
  )
end
