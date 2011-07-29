require File.expand_path('../boot', __FILE__)

require 'rails/all'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

module BigTuna
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/lib)

    # http authentication if the htpasswd is available. If you only want this is in production
    # then move the code out to the environments/production.rb, see
    #    http://stackoverflow.com/questions/3588951/warden-vs-rackauthbasic-doing-http-basic-auth-in-ruby-framework
    # for details.
    htpwdfile = File.join(Rails.root, 'config', 'htpasswd')
    if File.exists?(htpwdfile)
      puts " !!! Found htpasswd, will activate basic authentication"
      realm, cashname = "Yummy Fish", "_http_auth_passwd_"

      # read the htpasswd file here so that in case there is an issue, we crash on
      # start of the application and not on the first request.
      htpasswdlookup = Hash[File.read(htpwdfile).split.map { |a| a.split(/:/) }]

      # we store the htpasswdlookup in the rails cache so that we can manipulate it
      # at runtime and don't have to restart the application. Of course, we can only
      # add people to the htpasswd at runtime but we can't deactivate HTTP Authentication -
      # this will require a restart.
      config.middleware.
        insert_after(::Rack::Lock, "::Rack::Auth::Basic", realm) do |u, p|
        Rails.cache.write(cashname,htpasswdlookup) if Rails.cache.read(cashname).nil?
        encpass = Rails.cache.read(cashname)[u.to_s]
        # Assume we're using basic crypt encryption for our passwords
        encpass && encpass == p.crypt(encpass[0..1])
      end
    end

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # JavaScript files you want as :defaults (application.js is always included).
    # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]
    Haml::Template.options[:ugly] = true
    # config.action_view.javascript_expansions[:defaults] = %w(jquery.min rails application)
  end
end
