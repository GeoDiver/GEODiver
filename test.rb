require 'json'


#
def download_geo_file(geo_accession)
  if geo_accession =~ /^GDS/
    remote_dir = generate_remote_gds_url(geo_accession)
    file = "#{geo_accession}.soft.gz"
  elsif geo_accession =~ /^GSE/
    remote_dir = generate_remote_gse_url(geo_accession)
    file = "#{geo_accession}_series_matrix.txt.gz"
  end
  output_dir = File.join(db_dir, geo_accession)
  FileUtils.mkdir(output_dir) unless Dir.exist? output_dir
  compressed = File.join(output_dir, file)
  logger.debug("Downloading from: #{remote_dir} ==> #{compressed}")
  `wget #{remote_dir} --output-document #{compressed}`
  logger.debug("Uncompressing file: #{compressed.gsub('.gz', '')}")
  system "gunzip --force -c #{compressed} > #{compressed.gsub('.gz', '')}"
  compressed.gsub('.gz', '')
end

#
def generate_remote_gds_url(geo_accession)
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

def generate_remote_gse_url(geo_accession)
  if geo_accession.length == 6
    remote_dir = 'ftp://ftp.ncbi.nlm.nih.gov//geo/series/GSEnnn/' \
                 "#{geo_accession}/matrix/" \
                 "#{geo_accession}_series_matrix.txt.gz"
  elsif geo_accession.length == 7
    dir_number = geo_accession.match(/GSE(\d)\d+/)[1]
    remote_dir = 'ftp://ftp.ncbi.nlm.nih.gov//geo/series/' \
                 "GSE#{dir_number}nnn/#{geo_accession}/matrix/" \
                 "#{geo_accession}_series_matrix.txt.gz"
  elsif geo_accession.length == 8
    dir_number = geo_accession.match(/GSE(\d\d)\d+/)[1]
    remote_dir = 'ftp://ftp.ncbi.nlm.nih.gov//geo/series/' \
                 "GSE#{dir_number}nnn/#{geo_accession}/matrix/" \
                 "#{geo_accession}_series_matrix.txt.gz"

  end
  remote_dir
end

# Loads the file into memory line by line
# Stop loading the file once it has read all the meta data.
def read_geo_file(file)
  data = []
  IO.foreach(file) do |line|
    break if line =~ /^#ID_REF/ || line =~ /^!series_matrix_table_begin/ 
    data << line
  end
  data.join
end

#
def parse_gds_db(d)
  {
    'Accession' => d.match(/\^DATASET = (.*)/)[1],
    'Title' => d.match(/!dataset_title = (.*)/)[1],
    'Description' => d.match(/!dataset_description = (.*)/)[1],
    'Sample_Organism' => d.match(/!dataset_platform_organism = (.*)/)[1],
    'Factors' => parse_gds_factors(d),
    'Reference' => d.match(/!Database_ref = (.*)/)[1],
    'Update_Date' => d.match(/!dataset_update_date = (.*)/)[1]
  }
end

def parse_gse_db(d)
  {
    'Accession' => d.match(/!Series_geo_accession\t"(.*)"/)[1],
    'Title' => d.match(/!Series_title\t"(.*)"/)[1],
    'Description' => d.match(/!Series_summary\t"(.*)"/)[1],
    'Sample_Organism' => parse_sample_organism(d),
    'Factors' => parse_gse_factors(d),
    'Reference' => d.match(/!Series_relation\t"(.*)"/)[1],
    'Update_Date' => d.match(/!Series_last_update_date\t"(.*)"/)[1]
  }
end

#
def parse_gds_factors(data)
  subsets = data.gsub(/\^DATA.*\n/, '').gsub(/\![dD]ata.*\n/, '')
  factors = {}
  subsets.lines.each_slice(5) do |subset|
    desc = subset[2].match(/\!subset_description = (.*)/)[1]
    type = subset[4].match(/\!subset_type = (.*)/)[1].gsub(' ', '.')
    factors[type] ||= {}
    factors[type][:options] = desc
    factors[type][:value] = type
  end
  factors
end

def parse_gse_factors(data)
  subsets = data.scan(/!Sample_characteristics_ch1\t(.*)/)
  factors = {}
  subsets.each_with_index do |feature, idx|
    a = feature[0].split(/\"?\t?\"/)
    a.delete_if { |e| e =~ /^\s+$/ || e.empty? }
    a.each do |e|
      split = e.split(': ')
      type = split[0]
      factors[type] ||= {}
      factors[type][:value] = "Sample_characteristics_ch1.#{idx}"
      factors[type][:value].gsub!(/.0$/, '') if idx == 0
      factors[type][:options] ||= []
      factors[type][:options] << split[1]
    end
  end
  factors.each { |_, e| e[:options].uniq! }
  factors.delete_if { |_, e| e[:options].size == 1 }
  factors
end

def parse_sample_organism(data)
  subset = data.match(/!Sample_organism_ch1\t(.*)/)[1]
  organism = subset.split(/\"?\t?\"/)
  organism.shift
  organism.uniq
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
  if geo_accession =~ /^GDS/
    filename = "#{geo_accession}.soft.gz"
  elsif geo_accession =~ /^GSE/
    filename = "#{geo_accession}_series_matrix.txt.gz"
  end
  geo_db_dir = File.join(db_dir, geo_accession)
  "Rscript #{File.join(GeoDiver.root, 'RCore/download_GEO.R')}" \
  " --accession #{geo_accession}" \
  " #{geo_db_path(geo_accession, geo_db_dir)}"\
  " --outrdata  #{File.join(geo_db_dir, "#{geo_accession}.RData")}" \
  " && echo 'Finished creating Rdata file:" \
  " #{File.join(geo_db_dir, "#{geo_accession}.RData")}'"
end

def geo_db_path(geo_accession, geo_db_dir)
  if geo_accession =~ /^GDS/
    "--geodbpath #{File.join(geo_db_dir, "#{geo_accession}.soft.gz")}"
  else
    "--geodbpath #{File.join(geo_db_dir, "#{geo_accession}_series_matrix.txt.gz")}"
  end
end


file = '../GSE51808_series_matrix.txt'
data = read_geo_file(file)
r = parse_gse_db(data)

puts r.to_json
# parse_gds_db(data)


