# -*- ruby -*-
source 'http://rubygems.org'

gem "rails", "3.0.10"
gem "sqlite3-ruby"
gem "haml"
gem 'daemon-spawn', :git => 'https://github.com/alexvollmer/daemon-spawn.git', :require => 'daemon_spawn'
gem "delayed_job"
gem "stringex"
gem "open4"
gem "json"
gem 'jquery-rails'

gem 'mysql2', '< 0.3'

# ruby 1.9 compatible version
gem "scashin133-xmpp4r-simple", '0.8.9', :require => 'xmpp4r-simple'

# irc notification
gem "shout-bot"

# notifo notifications
gem "notifo"

# campfire notifications
gem "tinder"

# deployment
gem 'capistrano'
gem 'capistrano-ext'
gem 'gccommon', :git => 'git@dev.foxga.me:gccommon.git'
gem 'rake', "0.8.7"
gem 'whenever', :git => "https://github.com/javan/whenever.git"

group :development, :test do
  gem "capybara"
  gem "launchy"
  gem "faker"
  gem "machinist"
  gem "nokogiri"
  gem "mocha"
  gem "database_cleaner"
  gem "crack"
  gem "webmock"

  platforms :mri_18 do
    gem "ruby-debug"
  end

  platforms :mri_19 do
    gem "ruby-debug19"
  end
end

group :production do
  gem 'thin'
  gem 'eventmachine'
  gem 'daemons'
  gem 'unicorn'
end
