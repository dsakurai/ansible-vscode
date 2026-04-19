# My Dotfiles Generator

This project generates my personal dotfiles.

This project updates existing settings or generate a new settings files.
It keeps a back up of the old version.

Go to [`demo`](demo) for example settings files generated.

## How to Use This Project
The script will ask you where the VS Code settings directory lies.

Optionally, if you have existing settings directory that is inaccessible from this script, you can copy them in any accesible directory and run this script.

Run the following:
```
./generate-vscode-settings.rb
```

This will ask a few questions on the output directory and setting values.

## Demo

The following command will generate the default settings in the [`demo`](demo) directory.
```
./generate-vscode-settings.rb -d
```

## Maintenance

Run 
```
./generate-vscode-settings.rb -d
```
and add the generated settings file in git.

## Development

To expose a new file (like a settings file for VSCode, neovim, etc.) from the Ansible roles I use for other purposes but is still visible in this repository, what you need to do is...

1. Find the Ansible task that generates the file in `ansible_collections/dsakurai/common/`. 
2. The file is in the usual `copy` or `block-in-file` or another task.
3. Extract the parent directory of the file as an Ansible variable.
4. The default should be kept in the role and not moved out of it. If it makes sense, you can set a default value following the Ansible role convention.
5. Finally, set and pass the variable from `generate-vcode-settings.rb`
6. The hash map `roles` in that ruby file exposes the role and the variable to the user
6. Some sensible default should be supplied for the `demo_mode`
