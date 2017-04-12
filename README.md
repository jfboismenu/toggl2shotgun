# toggl2shotgun
Syncs data back and forth between Shotgun and Toggl

This package allows to take Shotgun tickets and turn them into Toggl projects (`shotgun2toggl`) and to take Toggl event data and submit them as Time Logs on Shotgun tickets (`toggl2shotgun`).

Both scripts will ask for your Shotgun and Toggl credentials on startup and will save them in a file name `~/.toggl2shotgun`. It will reuse them on successive runs.

## Before first use

1. Open a Toggl account at [toggl.com/signup](https://toggl.com/signup). It's FREE!
2. Go to your [profile](https://toggl.com/app/profile) page and get your API token. Keep that page open because you will need it the first time you launch any of the scripts.
3. Visit your [workspaces](https://toggl.com/app/workspaces) page and create a workspace named `Shotgun`. This is where your tickets will be tracked.

## shotgun2toggl

This script will create Toggl projects with the name `#shotgun_ticket_number shotgun_ticket_title` inside Toggl's `Shotgun` workspace. If the project already exists, it will ensure that the `shotgun_ticket_tile` part is up to date with the title in Shotgun.

## toggl2shotgun

This script will create Shotgun Time Logs on tickets for every project time log that exist in Toggl for the last 7 days. You can change the period of time using the `--start` and `-end` command line arguments.

# toggl.rb

## Before first use
WITH YOUR **SYSTEM** RUBY (`/usr/local/bin/ruby` (for RVM: `rvm use system`)) run: `gem install bundler; bundle install`

## Commands

* `ruby toggl.rb stop` => Stop current toggl task
* `ruby toggl.rb start 21636 Code and test` => Start a new task on ticket #21636 with "Code and test" as a description
* `ruby toggl.rb restart` => Restart previous task

# Alfred integration

## Before first use

1. Verify that your python and ruby scripts work
2. Add Toggl_to_shotgun.alfredworkflow to your alfred
3. Configure the `absolute_tool_path` of your workflow to the absolute path of this tool

## Commands

* t2s => Sync everything from toggl to shotgun
* s2t => Sync everything from shotgun to toggl
* tog start 21636 Code and test => Start a new task on ticket #21636 with "Code and test" as a description
* tog stop => Stop current Toggl task
* tog restart => Restart previous Toggl task
