require 'rake/clean'

directory 'data'

desc 'Prepare input CSV file by querying content store database'
file 'data/raw.csv' => 'data' do
  query_file = File.join(File.dirname(__FILE__), 'query.sql')
  output = File.join(File.dirname(__FILE__), 'data', 'raw.csv')

  sh "govuk-docker up -d content-store-lite"
  sh "docker exec -i govuk-docker-content-store-lite-1 rails db < #{query_file} > #{output}"
  sh "govuk-docker down content-store-lite"
end

task :default => ['data/raw.csv']
CLOBBER.include('data')
