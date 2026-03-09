require 'rake/clean'
require 'csv'
require 'nokogiri'
require 'json'

directory 'data'
directory 'input'

desc 'Prepare input CSV file by querying content store database'
file 'data/raw.csv' => 'data' do
  query_file = File.join(File.dirname(__FILE__), 'query.sql')
  output = File.join(File.dirname(__FILE__), 'data', 'raw.csv')

  sh "govuk-docker up -d content-store-lite"
  sh "docker exec -i govuk-docker-content-store-lite-1 rails db < #{query_file} > #{output}"
  sh "govuk-docker down content-store-lite"
end

def raw_data
  @data ||= CSV.read('data/raw.csv', headers: true)
end

def raw_data_ids
  raw_data.map { |row| row['id'] }
end

def strip_tags(s)
  Nokogiri.HTML(s).text.gsub(/\\n\s*/, " ")
end

raw_data_ids.each do |id|
  desc "Prepare input file #{id}.json"
  file "input/#{id}.json" => ['input', 'data/raw.csv'] do |f|
    data = raw_data.find {|r| r['id'] == id}

    File.write(
      f.name,
      JSON.pretty_generate(
        {
          title: data['title'],
          body: strip_tags(data['body'])
        }))
  end
end

desc 'Regenerate all files in input/'
task :inputs => raw_data_ids.map { |id| "input/#{id}.json" }

task :setup => ['data/raw.csv']

task :default do
  Rake::Task['setup'].invoke
  exec('rake', 'inputs')
end

CLOBBER.include('data', 'input')
