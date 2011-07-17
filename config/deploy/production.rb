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

templates do
  config(:monitrc) do
    services({ "ci.spawn.vc" => {
                 :daemons => ["unicorn"],
                 :scripts => ["delayed_job"]
               }})

    delayed_job_priorities({"ci.spawn.vc" => 10.times.collect { |a| "#{a} #{a}" } + ["10"]})
  end

  config([:unicorn, "unicorn.rb"]) do
    num_of_servers       4
    environment          "production"
    max_persistent_conns 64
    rails_version        :three
  end

  config(:monit_delayed_job) do
    environment "production"
  end
end
