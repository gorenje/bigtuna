##
## deploy for production
##

SERVERS = [
           ["ci.spawn.vc", nil, "ci.spawn.vc"],
          ]

role :db, "ci.spawn.vc", :primary => true

SERVERS.each do |name, ip, monit|
  role :app, name, :host_ip => ip || dnslookup(name)
  role :web, name
end

MONIT_SERVICES = {
  "ci.spawn.vc" => {
    :daemons => ["nginx"],
    :scripts => []
  },
}

set :monit_delayed_job_priorities, ["1 1", "2 15"]
set :monit_nginx_init_script,      "/etc/init.d/nginx"
set :monit_server_name,            "VIEW"
set :monit_alert_emails,           ["gerrit.riessen@gmail.com"]
set :monit_monitor_interval,       123
set :monit_system_name,            monit_server_name(SERVERS)
set :monit_include_include,        false
set :monit_script_user,            "#{user}.#{user}"
set :monit_services,               MONIT_SERVICES
set :monit_require_server,         false
set :monit_smtp_address,           "mx.spawn.vc"
set :monit_smtp_port,              25

# total memory usage (in MB) before script is restarted
set :monit_scripts_total_memory, "200.0"
set :monit_advertiser_importer_total_memory, "500.0"

#
# Nginx config
#  first common
set :ngx_using_thin, false
set :ngx_using_unicorn, true

set :ngx_has_htpasswd, true
set :ngx_server_names, ["ci.foxga.me", "ci.spawn.vc"]
set :ngx_ports, ["80"]

#  thin specific
set :ngx_thin_sockets, 5
#  unicorn specific
set :ngx_unicorn_port, 9000

#
# Unicorn.rb configuration
#
set :unicorn_num_of_servers,       4
set :unicorn_environment,          "production"
set :unicorn_max_persistent_conns, 64
