require 'base64'
require 'json'
require 'omniauth'
require 'omniauth-google-oauth2'
require 'sinatra/base'
require 'slim'
require 'slim/smart'

require 'geodiver/load_geo_db'
require 'geodiver/geo_analysis'
require 'geodiver/geo_analysis_helper'
require 'geodiver/history'
require 'geodiver/version'

module GeoDiver
  # Sinatra Routes - i.e. The Controller
  class Routes < Sinatra::Base
    # See http://www.sinatrarb.com/configuration.html
    configure do
      # We don't need Rack::MethodOverride. Let's avoid the overhead.
      disable :method_override

      # Ensure exceptions never leak out of the app. Exceptions raised within
      # the app must be handled by the app. We do this by attaching error
      # blocks to exceptions we know how to handle and attaching to Exception
      # as fallback.
      disable :show_exceptions, :raise_errors

      # Make it a policy to dump to 'rack.errors' any exception raised by the
      # app so that error handlers don't have to do it themselves. But for it
      # to always work, Exceptions defined by us should not respond to `code`
      # or http_status` methods. Error blocks errors must explicitly set http
      # status, if needed, by calling `status` method.
      enable :dump_errors

      # We don't want Sinatra do setup any loggers for us. We will use our own.
      set :logging, nil

      # Use Rack::Session::Pool over Sinatra default sessions.
      use Rack::Session::Pool, expire_after: 2_592_000 # 30 days

      # Provide OmniAuth the Google Key and Secret Key for Authentication
      use OmniAuth::Builder do
        provider :google_oauth2, ENV['GOOGLE_KEY'], ENV['GOOGLE_SECRET'],
                 provider_ignores_state: true, verify_iss: false
      end

      # view directory will be found here.
      set :root, -> { GeoDiver.root }

      # This is the full path to the public folder...
      set :public_folder, -> { GeoDiver.public_dir }
    end

    helpers do
      # Overide default URI helper method - to hardcode a https://
      # In our setup, we are running passenger on http:// (not secure) and then
      # reverse proxying that onto a 443 port (i.e. https://)
      # Generates the absolute URI for a given path in the app.
      # Takes Rack routers and reverse proxies into account.
      def uri(addr = nil, absolute = true, add_script_name = true)
        return addr if addr =~ /\A[a-z][a-z0-9\+\.\-]*:/i
        uri = [host = '']
        if absolute
          host << (GeoDiver.ssl? ? 'https://' : 'http://')
          if request.forwarded? || request.port != (request.secure? ? 443 : 80)
            host << request.host_with_port
          else
            host << request.host
          end
        end
        uri << request.script_name.to_s if add_script_name
        uri << (addr ? addr : request.path_info).to_s
        File.join uri
      end

      def base_url
        proxy = GeoDiver.ssl? ? 'https' : 'http'
        @base_url ||= "#{proxy}://#{request.env['HTTP_HOST']}"
      end
    end

    # For any request that hits the app, log incoming params at debug level.
    before do
      logger.debug params
    end

    # Home page (marketing page)
    get '/' do
      slim :home, layout: false
    end

    # Analyse Page
    get '/analyse' do
      slim :search, layout: :app_layout
    end

    # My Results Page
    get '/my_results' do
      redirect to('auth/google_oauth2') if session[:user].nil?
      @my_results = History.run(session[:user].info['email'])
      slim :my_results, layout: :app_layout
    end

    # Individual Result Pages
    get '/result/:encoded_email/:geo_db/:time' do
      email = Base64.decode64(params[:encoded_email])
      if session[:user].nil? && email != 'geodiver'
        redirect to('auth/google_oauth2')
      end
      json_file = File.join(GeoDiver.public_dir, 'GeoDiver/Users/', email,
                            params['geo_db'], params['time'], 'params.json')
      @results  = JSON.parse(IO.read(json_file))
      slim :single_results, layout: :app_layout
    end

    # Shared Result Pages (Can be viewed without logging in)
    get '/sh/:encoded_email/:geo_db/:time' do
      email     = Base64.decode64(params[:encoded_email])
      json_file = File.join(GeoDiver.public_dir, 'GeoDiver/Share/', email,
                            params['geo_db'], params['time'], 'params.json')
      @results  = JSON.parse(IO.read(json_file))
      slim :single_results, layout: :app_layout
    end

    get '/exemplar_results' do
      exemplar_results = GeoDiver.exemplar_results
      puts exemplar_results
      json_file = File.join(GeoDiver.public_dir, 'GeoDiver/Users/',
                            exemplar_results, 'params.json')
      @results  = JSON.parse(IO.read(json_file))
      slim :single_results, layout: :app_layout
    end

    get '/faq' do
      slim :faq, layout: :app_layout
    end

    # Load the Geo Database
    post '/load_geo_db' do
      @geo_db_results = LoadGeoData.run(params)
      # Convert the GeoDb into RData in the background if necessary
      session[:geodb] = LoadGeoData.convert_geodb_into_rdata(params['geo_db'])
      slim :load_db, layout: false
    end

    # Run the GeoDiver Analysis
    post '/analyse' do
      email    = Base64.decode64(params[:user])
      @results = GeoAnalysis.run(params, email, base_url, session[:geodb])
      slim :results, layout: false
    end

    # Generate and return a JSON object for the Gene Expression Results
    post '/gene_expression_graph' do
      content_type :json
      email = Base64.decode64(params[:user])
      GeoAnalysisHelper.get_expression_json(params, email)
    end

    # Generate the Interaction Netwoks
    post '/interaction_image' do
      email            = Base64.decode64(params[:user])
      @interaction_img = GeoAnalysisHelper.create_interactions(params, email)
      slim :interactionNetwork, layout: false
    end

    # Create a share link for a result page
    post '/sh/:encoded_email/:geo_db/:time' do
      email    = Base64.decode64(params[:encoded_email])
      analysis = File.join(GeoDiver.users_dir, email, params['geo_db'],
                           params['time'])
      share    = File.join(GeoDiver.public_dir, 'GeoDiver/Share', email,
                           params['geo_db'])
      FileUtils.mkdir_p(share) unless File.exist? share
      FileUtils.cp_r(analysis, share)
      share_file = File.join(analysis, '.share')
      FileUtils.touch(share_file) unless File.exist? share_file
    end

    # Remove a share link of a result page
    post '/rm/:encoded_email/:geo_db/:time' do
      email = Base64.decode64(params[:encoded_email])
      share = File.join(GeoDiver.public_dir, 'GeoDiver/Share', email,
                        params['geo_db'], params['time'])
      FileUtils.rm_r(share) if File.exist? share
      share_file = File.join(GeoDiver.users_dir, email, params['geo_db'],
                             params['time'], '.share')
      FileUtils.rm(share_file) if File.exist? share_file
    end

    # Delete a Results Page
    post '/delete_result' do
      email = session[:user].nil? ? 'geodiver' : session[:user].info['email']
      @results_url = File.join(GeoDiver.users_dir, email, params['geo_db'],
                               params['result_id'])
      FileUtils.rm_r @results_url if Dir.exist? @results_url
    end

    get '/auth/:provider/callback' do
      content_type 'text/plain'
      session[:user] = env['omniauth.auth']
      user_dir    = File.join(GeoDiver.users_dir, session[:user].info['email'])
      user_public = File.join(GeoDiver.public_dir, 'GeoDiver/Users')
      FileUtils.mkdir(user_dir) unless Dir.exist?(user_dir)
      unless File.exist? File.join(user_public, session[:user].info['email'])
        FileUtils.ln_s(user_dir, user_public)
      end
      redirect '/analyse'
    end

    post '/auth/:provider/callback' do
      content_type :json
      session[:user] = env['omniauth.auth']
      user_dir    = File.join(GeoDiver.users_dir, session[:user].info['email'])
      user_public = File.join(GeoDiver.public_dir, 'GeoDiver/Users')
      FileUtils.mkdir(user_dir) unless Dir.exist?(user_dir)
      unless File.exist? File.join(user_public, session[:user].info['email'])
        FileUtils.ln_s(user_dir, user_public)
      end
      env['omniauth.auth'].to_json
    end

    get '/logout' do
      user_public_dir = File.join(GeoDiver.public_dir, 'GeoDiver/Users',
                                  session[:user].info['email'])
      FileUtils.rm(user_public_dir)
      session[:user] = nil
      redirect '/analyse'
    end

    get '/auth/failure' do
      redirect '/analyse'
    end

    # Recaptcha
    # https://stackoverflow.com/questions/21262254/what-captcha-for-sinatra
    #

    # This error block will only ever be hit if the user gives us a funny
    # sequence or incorrect advanced parameter. Well, we could hit this block
    # if someone is playing around with our HTTP API too.
    error LoadGeoData::ArgumentError, GeoAnalysis::ArgumentError do
      status 400
      slim :"500", layout: false
    end

    # This will catch any unhandled error and some very special errors. Ideally
    # we will never hit this block. If we do, there's a bug in GeneValidatorApp
    # or something really weird going on.
    # TODO: If we hit this error block we show the stacktrace to the user
    # requesting them to post the same to our Google Group.
    error Exception, LoadGeoData::RuntimeError, GeoAnalysis::RuntimeError do
      status 500
      slim :"500", layout: false
    end

    not_found do
      status 404
      slim :"404", layout: :app_layout
    end
  end
end
