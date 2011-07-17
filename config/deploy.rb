set :stages, %w(production prodbackup beta staging)
set :default_stage, "staging"

require 'capistrano/ext/multistage'
require 'gccommon/deploy_helpers.rb'

# Deployment now depended on the user and the application. The application is
# basically the git repo name, while the user is the directory on the server
# which also happens to be the home directory of the user.
set :application,           "bigtuna"
set :user,                  "bigtuna"
set :deploy_to,             "/var/app/#{user}"
set :local_rails_root,      File.expand_path(File.join(File.dirname(__FILE__), ".."))

set :scm,                   :git
set :repository,            "git@dev.foxga.me:#{ENV['GITREPO'] || application}.git"
set :superglue_repository,  "git@dev.foxga.me:superglue.git"
set :branch,                ENV["GITBRANCH"] || "master"
set :git_shallow_clone,     3
set :git_enable_submodules, 1 ## note, this does not work for deep modules only toplevel

namespace :deploy do
  { ### After hooks
    "migrate"          => "restart",
    "setup_paths"      => ["generate_remote_files", "crontab:create"], #, "monit:reload"],
    "rvm:install_ruby" => "bundler:install",
    "symlink"          => "crontab:install",
  }.each do |after_task, before_tasks|
    [before_tasks].flatten.each do |before_task|
      after "deploy:#{after_task}", "deploy:#{before_task}"
    end
  end

  { ### Before hooks
    # do all the heavy lifting before we change the current symlink.
    # Note all these tasks don't use current_path, they use release_path
    # because the current_path is only correct *after* symlink.
    "symlink"       => ["setup_diff", "rvm:install_ruby", "setup_paths"],
    "setup_paths"   => ["superglue:update", "crontab:clear"],
    "restart"       => ["show_diffs", "delayed_job:restart"],
  }.each do |before_task, after_tasks|
    [after_tasks].flatten.each do |after_task|
      before "deploy:#{before_task}", "deploy:#{after_task}"
    end
  end

  desc "create various paths and replace symlinks"
  task :setup_paths do
    base_config_dir = "~/superglue.#{application}/config/#{application}/#{stage}"
    [
     # system folder is only used for maintenance, therefore whip it's ass
     ["public/system", "#{shared_path}/system/maintenance"],
     ["builds", "#{shared_path}/builds"],
     ["db/production.sqlite", "#{shared_path}/db/production.sqlite"],

     # various yaml configurations
     ["config/database.yml", "#{base_config_dir}/database.yml"],
     ["config/htpasswd",     "#{base_config_dir}/htpasswd"],
     ["config/email.yml",    "#{base_config_dir}/email.yml"],
     ["config/bigtuna.yml",  "#{base_config_dir}/bigtuna.yml"],

     # redirect the log symlink for log
     ["log", "#{shared_path}/log"],
    ].each do |dest, src|
      dest = "#{release_path}/#{dest}"
      run "rm -fr #{dest} && ln -snf #{src} #{dest}"
    end
  end

  desc "Generate files on the remote server"
  task :generate_remote_files do
    {
      "template:monitrc"           => "file://#{deploy_to}/.monitrc.local",
      "template:unicorn.rb"        => "#{shared_path}/config",
      "template:unicorn"           => "#{release_path}/script",
      "template:delayed_job"       => "#{release_path}/script",
      "template:monit_delayed_job" => "#{release_path}/script",
    }.each { |configfile, remote_path| push_remote_file(configfile, remote_path, @diff) }
  end
end
