require 'bundler/gem_tasks'

task default: [:build]

desc 'Builds and installs'
task install: [:installRdependencies, :build] do
  require_relative 'lib/geodiver/version'
  sh "gem install ./geodiver-#{GeoDiver::VERSION}.gem"
end

desc 'Runs tests and builds gem (default)'
task :build do
  sh 'gem build geodiver.gemspec'
end

desc 'Install R dependencies'
task :installRdependencies do
  sh 'Rscript RCore/installations.R'
end

task test: :spec do
  require 'rspec/core'
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec) do |spec|
    spec.pattern = FileList['spec/**/*_spec.rb']
  end
end

task :assets do
  require_relative 'lib/geodiver/version'
  `rm ./public/assets/css/style-*.min.css`
  `rm ./public/assets/css/style-*.min.css.map`
  sh 'sass -t compressed ./public/assets/css/scss/materialize.scss' \
     " ./public/assets/css/style-#{GeoDiver::VERSION}.min.css"
  `rm ./public/assets/js/geodiver-*.min.js`
  sh "uglifyjs './public/assets/js/dependencies/datatable-materialize.js'" \
     " './public/assets/js/dependencies/jquery.filedownload.min.js'" \
     " './public/assets/js/geodiver.js' -m -c --source-map  -o" \
     " './public/assets/js/geodiver-#{GeoDiver::VERSION}.min.js'"
end

task :criticalcss do
  require_relative 'lib/geodiver'
  puts 'Note that GeoDiver needs to be running on Port 9292 for this to work'
  puts 'You will need to manually insert the Critical CSS'
  puts 'You run `npm install` before running this rake command'
  `rm ./public/assets/css/criticl/home.min.css`
  `rm ./public/assets/css/criticl/app.min.css`
  `rm ./public/assets/css/criticl/exemplar_results.min.css`
  sh "node #{File.join(GeoDiver.root, 'public/assets/css/critical/critical.js')}"
end
