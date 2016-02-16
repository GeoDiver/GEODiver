require 'forwardable'
require 'json'

# GeoDiver NameSpace
module GeoDiver
  # Module with Helper Methods
  module GeoAnalysisHelper
    # To signal error in query sequence or options.
    #
    # ArgumentError is raised when ... exit status is 1; see [1].
    class ArgumentError < ArgumentError
    end

    # To signal internal errors.
    #
    # RuntimeError is raised when there is a problem in writing the input file,
    # running R Script, writing the output etc. These are rare, infrastructure
    # errors, used internally, and of concern only to the admins/developers.
    # One example of a RuntimeError would be R libraries not installed.
    class RuntimeError < RuntimeError
    end

    class << self
      extend Forwardable

      def_delegators GeoDiver, :config, :logger, :public_dir, :users_dir,
                     :db_dir

      def get_expression_json(params, email)
        assert_gene_id_present(params)
        run_dir = run_expression_analysis(params, email)
        jsonfile = File.join(run_dir, "dgea_#{params[:gene_id]}.json")
        json     = IO.read(jsonfile)
        json
      end

      def create_interactions(params, email)
        run_interaction_analysis(params, email)
        run_dir = generate_relative_results_link(email, params['geo_db'],
                                                 params['result_id'])
        File.join(run_dir, "#{params[:path_id]}.gage_pathway.multi.png")
      end

      private

      def assert_gene_id_present(params)
        logger.debug('Asserting Gene ID is present.')
        return unless params['gene_id'].nil? || params['gene_id'].empty?
        fail ArgumentError, 'No Gene Id provided.'
      end

      def run_expression_analysis(params, email)
        run_dir = File.join(users_dir, email, params['geo_db'],
                            params['result_id'])
        cmd = expression_cmd(run_dir, params)
        logger.debug("Running CMD: #{cmd}")
        system(cmd)
        assert_expression_output
        run_dir
      end

      def expression_cmd(run_dir, params)
        "Rscript #{File.join(GeoDiver.root, 'RCore/dgea_expression.R')}" \
        " --rundir '#{run_dir}/' --geneid '#{params[:gene_id]}'"
      end

      def assert_expression_output
        true
      end

      def run_interaction_analysis(params, email)
        run_dir = File.join(users_dir, email, params['geo_db'],
                            params['result_id'])
        output_file = File.join(run_dir, 
                                "#{params[:path_id]}.gage_pathway.multi.png")
        unless File.exist? output_file
          logger.debug("Running CMD: #{interaction_cmd(run_dir, params)}")
          Dir.chdir(run_dir) { system(interaction_cmd(run_dir, params)) } 
          remove_unwanted_files(run_dir, params)
        end
        assert_expression_output
      end

      def interaction_cmd(run_dir, params)
        "Rscript #{File.join(GeoDiver.root, 'RCore/gage_interaction.R')}" \
        " --rundir '#{run_dir}/' --pathid '#{params[:path_id]}'"
      end

      def remove_unwanted_files(run_dir, params)
        if File.exist? File.join(run_dir, "#{params[:path_id]}.png")
          FileUtils.rm(File.join(run_dir, "#{params[:path_id]}.png"))
        end
        if File.exist? File.join(run_dir, "#{params[:path_id]}.xml")
          FileUtils.rm(File.join(run_dir, "#{params[:path_id]}.xml"))
        end
      end

      def generate_relative_results_link(email, geo_accession, uniq_time)
        File.join('GeoDiver/Users/', email, geo_accession, uniq_time)
      end
    end
  end
end