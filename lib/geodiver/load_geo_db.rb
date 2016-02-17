require 'json'
# GeoDiver NameSpace
module GeoDiver
  # module to run the Load the GEO dataset.
  module LoadGeoData
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

      def_delegators GeoDiver, :logger, :public_dir, :db_dir

      # Check if the GEO database has already been downloaded, if not, then
      # download the GEO dataset and extract the meta data and convert into
      # RData
      def run(params)
        init(params)
        geo_accession = params['geo_db'].upcase
        meta_json_file = File.join(db_dir, geo_accession,
                                   "#{geo_accession}.json")
        if File.exist? meta_json_file
          logger.debug("Found GeoDb at: '#{meta_json_file}'")
          logger.debug("Parsing GeoDb '#{geo_accession}'")
          meta_data = parse_meta_data(meta_json_file)
        else
          logger.debug("Local GeoDb for '#{geo_accession}' not found.")
          meta_data = download_and_parse_meta_data(geo_accession)
          write_to_json(meta_data, meta_json_file)
        end
        soft_link_meta_json_to_public_dir(geo_accession, meta_json_file)
        logger.debug("GeoDb loaded into memory")
        meta_data
      end

      def convert_geodb_into_RData(geo_accession)
        geo_accession = geo_accession.upcase
        return if File.exist?(File.join(db_dir, geo_accession,
                                        "#{geo_accession}.RData"))
        logger.debug("Running: #{load_geo_db_cmd(geo_accession)}")
        Thread.new { system(load_geo_db_cmd(geo_accession)) }
        # TODO check exit status of the system call
      end

      private

      # Verify paramaters
      def init(params)
        assert_geo_db_present(params)
      end

      #
      def assert_geo_db_present(params)
        logger.debug('Checking if the GEO DB parameter is present.')
        return unless params['geo_db'].nil? || params['geo_db'].empty?
        fail ArgumentError, 'No GEO database provided.'
      end

      def parse_meta_data(meta_json_file)
        logger.debug("Parse the Meta JSON file at: #{meta_json_file}")
        meta_file_content = IO.read meta_json_file
        JSON.parse(meta_file_content)
      end

      #
      def download_and_parse_meta_data(geo_accession)
        file = download_geo_file(geo_accession)
        data = read_geo_file(file)
        parse_geo_db(data)
      end

      #
      def download_geo_file(geo_accession)
        remote_dir = generate_remote_url(geo_accession)
        output_dir = File.join(db_dir, geo_accession)
        FileUtils.mkdir(output_dir) unless Dir.exist? output_dir
        compressed = File.join(output_dir, "#{geo_accession}.soft.gz")
        logger.debug("Downloading from: #{remote_dir} ==> #{compressed}")
        system "wget #{remote_dir} --output-document #{compressed}" \
               ' >/dev/null 2>&1'
        logger.debug("Uncompressing file: #{compressed.gsub('.gz', '')}")
        system "gunzip --force -c #{compressed} > #{compressed.gsub('.gz', '')}"
        compressed.gsub('.gz', '')
      end

      #
      def generate_remote_url(geo_accession)
        if geo_accession.length == 6
          remote_dir = 'ftp://ftp.ncbi.nlm.nih.gov//geo/datasets/GDSnnn/' \
                       "#{geo_accession}/soft/#{geo_accession}.soft.gz"
        else
          dir_number = geo_accession.match(/GDS(\d)\d+/)[1]
          remote_dir = 'ftp://ftp.ncbi.nlm.nih.gov//geo/datasets/' \
                       "GDS#{dir_number}nnn/#{geo_accession}/soft/" \
                       "#{geo_accession}.soft.gz"
        end
        remote_dir
      end

      # Loads the file into memory line by line
      # Stop loading the file once it has read all the meta data.
      def read_geo_file(file)
        data = []
        IO.foreach(file) do |line|
          break if line =~ /^#ID_REF/
          data << line
        end
        data.join
      end

      #
      def parse_geo_db(data)
        {
          'Accession' => data.match(/\^DATASET = (.*)/)[1],
          'Title' => data.match(/!dataset_title = (.*)/)[1],
          'Description' => data.match(/!dataset_description = (.*)/)[1],
          'Sample_Organism' => data.match(/!dataset_platform_organism = (.*)/)[1],
          'Factors' => parse_factors(data),
          'Reference' => data.match(/!Database_ref = (.*)/)[1],
          'Update_Date' => data.match(/!dataset_update_date = (.*)/)[1]
        }
      end

      #
      def parse_factors(data)
        subsets = data.gsub(/\^DATA.*\n/, '').gsub(/\![dD]ata.*\n/, '')
        results = {}
        subsets.lines.each_slice(5) do |subset|
          desc = subset[2].match(/\!subset_description = (.*)/)[1]
          type = subset[4].match(/\!subset_type = (.*)/)[1].gsub(' ', '.')
          samples = subset[3].match(/\!subset_sample_id = (.*)/)[1]
          results[type] ||= []
          results[type] << desc
        end
        results
      end

      #
      def write_to_json(hash, output_json)
        logger.debug("Writing meta data to file: #{output_json}")
        File.open(output_json, 'w') { |f| f.puts hash.to_json }
      end

      #
      def soft_link_meta_json_to_public_dir(geo_accession, meta_json_file)
        public_meta_json = File.join(public_dir, 'GeoDiver/DBs/',
                                     "#{geo_accession}.json")
        logger.debug("Creating a Soft Link from: #{meta_json_file} ==>" \
                     " #{public_meta_json}")
        return if File.exist? public_meta_json
        FileUtils.ln_s(meta_json_file, public_meta_json)
      end

      #
      def load_geo_db_cmd(geo_accession)
        geo_db_dir = File.join(db_dir, geo_accession)
        "Rscript #{File.join(GeoDiver.root, 'RCore/download_GEO.R')}" \
        " --accession #{geo_accession}" \
        " --geodbpath #{File.join(geo_db_dir, "#{geo_accession}.soft.gz")}"\
        " --outrdata  #{File.join(geo_db_dir, "#{geo_accession}.RData")}" \
        " && echo 'Finished creating Rdata file:" \
        " #{File.join(geo_db_dir, "#{geo_accession}.RData")}'"
      end
    end
  end
end
