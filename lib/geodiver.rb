require 'yaml'
require 'fileutils'

require 'geodiver/config'
require 'geodiver/exceptions'
require 'geodiver/load_geo_db'
require 'geodiver/logger'
require 'geodiver/geo_analysis'
require 'geodiver/geo_analysis_helper'
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
      generate_exemplar_results

      self
    end

    attr_reader :config, :temp_dir, :public_dir, :users_dir, :db_dir,
                :exemplar_results

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
      host = 'localhost' if ['127.0.0.1', '0.0.0.0'].include? host
      proxy = GeoDiver.ssl? ? 'https' : 'http'
      "#{proxy}://#{host}:#{config[:port]}"
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

    # Test if the RCore is working and also produce the exemplar results
    def generate_exemplar_results
      logger.debug 'Testing RCore and producing Exemplar Results Page'
      session_geodb = load_geo_db
      email         = 'geodiver'
      r = GeoAnalysis.run(default_params, email, server_url, session_geodb)
      assert_rcore_works(r)
      @exemplar_results = File.join('geodiver', r[:geo_db], r[:uniq_result_id])
      logger.debug "Exemplar Results page is available at: #{r[:results_url]}"
    end

    def load_geo_db
      LoadGeoData.run('geo_db' => 'GDS724')
      LoadGeoData.convert_geodb_into_rdata('GDS724')
    end

    def assert_rcore_works(r)
      return if r[:overview_exit_code].zero? && r[:dgea_exit_code].zero? &&
                r[:gage_exit_code].zero?
      raise RCORE_FAILURE
    end

    def default_params
      { 'geo_db' => 'GDS724', 'user' => 'Z2VvZGl2ZXI=', 'factor' => 'tissue',
        'groupa' => ['peripheral blood lymphocyte'], 'groupb' => ['kidney'],
        'dgea' => 'on', 'dgea_toptable' => 'on',
        'dgea_number_top_genes' => '250',
        'dgea_volcano_pValue_cutoff' => 'fdr', 'dgea_heatmap' => 'on',
        'dgea_heatmap_rows' => '100',
        'dgea_heatmap_distance_method' => 'euclidean',
        'dgea_heatmap_clustering_method' => 'complete',
        'dgea_cluster_by_genes' => 'true', 'dgea_cluster_by_samples' => 'true',
        'dgea_cluster_based_on' => 'on',
        'dgea_volcano' => 'on', 'gsea' => 'on', 'gsea_type' => 'ExpVsCtrl',
        'gsea_control_group' => 'on', 'gsea_dataset' => 'KEGG',
        'gsea_heatmap' => 'on', 'gsea_heatmap_rows' => '100',
        'gsea_heatmap_distance_method' => 'euclidean',
        'gsea_heatmap_clustering_method' => 'complete',
        'gsea_cluster_by_genes' => 'true', 'gsea_cluster_by_samples' => 'true',
        'gsea_cluster_based_on' => 'on' }
    end
  end
end
