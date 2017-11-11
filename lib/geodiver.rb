require 'yaml'
require 'fileutils'

require 'geodiver/config'
require 'geodiver/exceptions'
require 'geodiver/logger'
require 'geodiver/routes'
require 'geodiver/server'
require 'geodiver/version'

# GeoDiver NameSpace
module GeoDiver
  class << self
    def environment
      ENV['RACK_ENV']
    end

    def verbose?
      @verbose ||= (environment == 'development')
    end

    def root
      File.dirname(File.dirname(__FILE__))
    end

    def ssl?
      @config[:ssl]
    end

    def logger
      @logger ||= Logger.new(STDOUT)
    end

    # Setting up the environment before running the app...
    # We don't validate port and host settings. If GeoDiver is run
    # self-hosted, bind will fail on incorrect values. If GeoDiver
    # is run via Apache/Nginx + Passenger, we don't need to worry.
    def init(config = {})
      @config = Config.new(config)
      Thread.abort_on_exception = true if verbose?


      init_dirs
      set_up_default_user_dir
      check_num_threads

      self
    end

    attr_reader :config, :temp_dir, :public_dir, :users_dir, :db_dir

    # Starting the app manually
    def run
      check_host
      Server.run(self)
    rescue Errno::EADDRINUSE
      puts "** Could not bind to port #{config[:port]}."
      puts "   Is GeoDiver already accessible at #{server_url}?"
      puts '   No? Try running GeoDiver on another port, like so:'
      puts
      puts '       geodiver -p 4570.'
    rescue Errno::EACCES
      puts "** Need root privilege to bind to port #{config[:port]}."
      puts '   It is not advisable to run GeoDiver as root.'
      puts '   Please use Apache/Nginx to bind to a privileged port.'
    end

    def on_start
      puts '** GeoDiver is ready.'
      puts "   Go to #{server_url} in your browser and start analysing GEO datasets!"
      puts '   Press CTRL+C to quit.'
      open_in_browser(server_url)
    end

    def on_stop
      puts
      puts '** Thank you for using GeoDiver :).'
      # Add Citation Notice Here
    end

    # Rack-interface.
    #
    # Inject our logger in the env and dispatch request to our controller.
    def call(env)
      env['rack.logger'] = logger
      Routes.call(env)
    end

    private

    # Set up the directory structure in @config[:gd_serve_dir]
    def init_dirs
      default_dirs
      init_public_dir
      FileUtils.mkdir_p @users_dir unless Dir.exist? @users_dir
      FileUtils.mkdir_p @db_dir unless Dir.exist? @db_dir
    end

    def default_dirs
      config[:gd_serve_dir] = File.expand_path config[:gd_serve_dir]
      @public_dir = File.join(config[:gd_serve_dir], 'public')
      @users_dir = File.join(config[:gd_serve_dir], 'Users')
      @db_dir = File.join(config[:gd_serve_dir], 'DBs')
      logger.debug "GeoDiver Directory: #{config[:gd_serve_dir]}"
      logger.debug "@public_dir Directory: #{@public_dir}"
      logger.debug "@users_dir Directory: #{@users_dir}"
      logger.debug "@db_dir Directory: #{@db_dir}"
    end

    # Public Directory structure
    def init_public_dir
      FileUtils.mkdir_p @public_dir unless Dir.exist?(@public_dir)
      root_assets = File.join(GeoDiver.root, 'public/assets')
      FileUtils.rm_rf(File.join(@public_dir, 'assets'))
      if environment == 'development'
        FileUtils.ln_s(root_assets, @public_dir)
      else
        FileUtils.cp_r(root_assets, @public_dir)
      end
      init_public_gd_dir(@public_dir)
    end

    def init_public_gd_dir(public_dir)
      root_gd = File.join(GeoDiver.root, 'public/GeoDiver')
      public_gd = File.join(public_dir, 'GeoDiver')
      return if File.exist?(public_gd)
      FileUtils.cp_r(root_gd, public_dir)
    end

    def set_up_default_user_dir
      user_dir    = File.join(GeoDiver.users_dir, 'geodiver')
      user_public = File.join(GeoDiver.public_dir, 'GeoDiver/Users')
      FileUtils.mkdir(user_dir) unless Dir.exist?(user_dir)
      return if File.exist? File.join(user_public, 'geodiver')
      FileUtils.ln_s(user_dir, user_public)
    end

    def check_num_threads
      config[:num_threads] = Integer(config[:num_threads])
      raise NUM_THREADS_INCORRECT unless config[:num_threads] > 0

      logger.debug "Will use #{config[:num_threads]} threads to run GeoDiver."
      return unless config[:num_threads] > 256
      logger.warn "Number of threads set at #{config[:num_threads]} is" \
                  ' unusually high.'
    end

    # Check and warn user if host is 0.0.0.0 (default).
    def check_host
      return unless config[:host] == '0.0.0.0'
      logger.warn 'Will listen on all interfaces (0.0.0.0).' \
                  ' Consider using 127.0.0.1 (--host option).'
    end

    def server_url
      host = config[:host]
      host = 'localhost' if host == '127.0.0.1' || host == '0.0.0.0'
      "http://#{host}:#{config[:port]}"
    end

    def open_in_browser(server_url)
      return if using_ssh? || verbose?
      if RUBY_PLATFORM =~ /linux/ && xdg?
        system "xdg-open #{server_url}"
      elsif RUBY_PLATFORM =~ /darwin/
        system "open #{server_url}"
      end
    end

    def using_ssh?
      true if ENV['SSH_CLIENT'] || ENV['SSH_TTY'] || ENV['SSH_CONNECTION']
    end

    def xdg?
      true if ENV['DISPLAY'] && system('which xdg-open > /dev/null 2>&1')
    end
  end
end
