require 'json'

data =<<EOS
!Sample_characteristics_ch1	"subject id: 3"	"subject id: 4"	"subject id: 6"	"subject id: 7"	"subject id: 32"	"subject id: 33"	"subject id: 34"	"subject id: 35"	"subject id: 36"	"subject id: 574328"	"subject id: 37"	"subject id: 38"	"subject id: 39"	"subject id: 40"	"subject id: 41"	"subject id: 42"	"subject id: 43"	"subject id: 44"	"subject id: 45"	"subject id: 47"	"subject id: 48"	"subject id: 49"	"subject id: 54"	"subject id: 55"	"subject id: 60"	"subject id: 66"	"subject id: 68"	"subject id: 80"	"subject id: 3"	"subject id: 4"	"subject id: 6"	"subject id: 33"	"subject id: 34"	"subject id: 35"	"subject id: 36"	"subject id: 37"	"subject id: 38"	"subject id: 39"	"subject id: 41"	"subject id: 44"	"subject id: 45"	"subject id: 47"	"subject id: 48"	"subject id: 49"	"subject id: 54"	"subject id: 55"	"subject id: 80"	"subject id: c3"	"subject id: c5"	"subject id: c4"	"subject id: c6"	"subject id: c1"	"subject id: c8"	"subject id: c7"	"subject id: c9"	"subject id: c2"
!Sample_characteristics_ch1	"infection: DENV"	"infection: DENV"	"infection: DENV"	"infection: DENV"	"infection: DENV"	"infection: DENV"	"infection: DENV"	"infection: DENV"	"infection: DENV"	"infection: DENV"	"infection: DENV"	"infection: DENV"	"infection: DENV"	"infection: DENV"	"infection: DENV"	"infection: DENV"	"infection: DENV"	"infection: DENV"	"infection: DENV"	"infection: DENV"	"infection: DENV"	"infection: DENV"	"infection: DENV"	"infection: DENV"	"infection: DENV"	"infection: DENV"	"infection: DENV"	"infection: DENV"	"infection: DENV"	"infection: DENV"	"infection: DENV"	"infection: DENV"	"infection: DENV"	"infection: DENV"	"infection: DENV"	"infection: DENV"	"infection: DENV"	"infection: DENV"	"infection: DENV"	"infection: DENV"	"infection: DENV"	"infection: DENV"	"infection: DENV"	"infection: DENV"	"infection: DENV"	"infection: DENV"	"infection: DENV"	"infection: control"	"infection: control"	"infection: control"	"infection: control"	"infection: control"	"infection: control"	"infection: control"	"infection: control"	"infection: control"
!Sample_characteristics_ch1	"status: DF"	"status: DF"	"status: DF"	"status: DF"	"status: DHF"	"status: DF"	"status: DHF"	"status: DF"	"status: DF"	"status: DHF"	"status: DF"	"status: DHF"	"status: DHF"	"status: DHF"	"status: DF"	"status: DF"	"status: DF"	"status: DF"	"status: DHF"	"status: DF"	"status: DHF"	"status: DHF"	"status: DF"	"status: DF"	"status: DHF"	"status: DF"	"status: DF"	"status: DF"	"status: convalescent"	"status: convalescent"	"status: convalescent"	"status: convalescent"	"status: convalescent"	"status: convalescent"	"status: convalescent"	"status: convalescent"	"status: convalescent"	"status: convalescent"	"status: convalescent"	"status: convalescent"	"status: convalescent"	"status: convalescent"	"status: convalescent"	"status: convalescent"	"status: convalescent"	"status: convalescent"	"status: convalescent"	"status: control"	"status: control"	"status: control"	"status: control"	"status: control"	"status: control"	"status: control"	"status: control"	"status: control"
!Sample_characteristics_ch1	"tissue: whole blood"	"tissue: whole blood"	"tissue: whole blood"	"tissue: whole blood"	"tissue: whole blood"	"tissue: whole blood"	"tissue: whole blood"	"tissue: whole blood"	"tissue: whole blood"	"tissue: whole blood"	"tissue: whole blood"	"tissue: whole blood"	"tissue: whole blood"	"tissue: whole blood"	"tissue: whole blood"	"tissue: whole blood"	"tissue: whole blood"	"tissue: whole blood"	"tissue: whole blood"	"tissue: whole blood"	"tissue: whole blood"	"tissue: whole blood"	"tissue: whole blood"	"tissue: whole blood"	"tissue: whole blood"	"tissue: whole blood"	"tissue: whole blood"	"tissue: whole blood"	"tissue: whole blood"	"tissue: whole blood"	"tissue: whole blood"	"tissue: whole blood"	"tissue: whole blood"	"tissue: whole blood"	"tissue: whole blood"	"tissue: whole blood"	"tissue: whole blood"	"tissue: whole blood"	"tissue: whole blood"	"tissue: whole blood"	"tissue: whole blood"	"tissue: whole blood"	"tissue: whole blood"	"tissue: whole blood"	"tissue: whole blood"	"tissue: whole blood"	"tissue: whole blood"	"tissue: whole blood"	"tissue: whole blood"	"tissue: whole blood"	"tissue: whole blood"	"tissue: whole blood"	"tissue: whole blood"	"tissue: whole blood"	"tissue: whole blood"	"tissue: whole blood"
EOS


subsets = data.scan(/!Sample_characteristics_ch1\s+(.*)/)


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

puts factors.to_json

#   # a.shift

#   # a.each do |e|
#   # end
# end
# factors