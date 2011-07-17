# The following are all passed to this schedule script. So that we know what
# generated the crontab, we echo them out to the crontab.
puts "# server:       #{forserver}"
puts "# environment:  #{environment}"
puts "# rel. path:    #{path}"
puts "# current path: #{currpath}"
puts "# revision:     #{revision}"
puts "# Rvm:          #{rvm_ruby_version}"

require 'gccommon/deploy_helpers/schedule_commands'

##
## Cronjob specifications.
##

# let us set the path variable
set("set_path_automatically", false)

# jobs for specific servers
case forserver

##
## production und staging servers
##
when "ci.spawn.vc"
  $stderr.puts "Nothing to do for crontab"

##
## production backup crontabs
##
when "ids01.sponsorpay.com"
  every(3.minutes) { scriptcmd("nfs_copy") }
  every(5.minutes) { supergluecmd("helpers/scripts/update_nginx_conf", :opts => "-p ids")}

  every(1.day, :at => "12:00 am") { myrake "ids:pcc:reset", :as_user => "deploy" }

  every(1.day, :at => "10:16 pm") do
    myrake "aff_net:dailyrun", :as_user => "deploy"
  end

when "ids02.sponsorpay.com"
  every(3.minutes) { scriptcmd("nfs_copy") }
  every(5.minutes) { supergluecmd("helpers/scripts/update_nginx_conf", :opts => "-p ids")}

  every(10.minutes) { supergluecmd("scripts/remove_blockables") }
  every(3.minutes) { supergluecmd("scripts/clean_up_delayed_jobs", :ignore_output => true) }

  every(3.minutes) do
    shcmd("/usr/bin/fetchmail", :opts => "-f #{path}/config/fetchmailrc",
          :as_user => "deploy")
  end

  every(1.day, :at => "9:32 am") do
    myrake("delayed_job:monitor:send_report", :as_user => "deploy")
  end

  every(:monday, :at => "8:32 am") do
    myrake("delayed_job:monitor:send_report_weekly", :as_user => "deploy")
  end

when "ids03.sponsorpay.com"
  every(3.minutes) { scriptcmd("nfs_copy") }
  every(5.minutes) { supergluecmd("helpers/scripts/update_nginx_conf", :opts => "-p ids")}

  every( 1.hours, :at => 1 ) do
    scriptcmd("cleanup_expired_chuck_user_counters", { :as_user => "deploy",
                                                       :opts => environment,
                                                       :ignore_output => true })
  end

  every( 1.hours, :at => 42 ) do
    scriptcmd("cleanup_expired_ip_payout_counters", { :as_user => "deploy",
                :opts => environment, :comment_out => true } )
  end

  every(15.minutes) do
    myrake("delayed_job:monitor:update_db", :as_user => "deploy",
           :env => { :LOG_POSTFIX => 'min1_to_max1' }, :ignore_output => true)
  end

else
  # force users to explicitly define jobs for servers. This is a warning system for
  # IP/Name changes in the deploy scripts.
  $stderr.puts "ERROR: Server #{forserver} has no crontab job(s). This should not happen."
  $stderr.puts "ERROR: It should at least have a dummy entry. This prevents IP/Name changes"
  $stderr.puts "ERROR: From causing problems (at least partially)."
  exit 1
end
