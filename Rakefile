require 'rake/clean'
require 'csv'
require 'nokogiri'
require 'json'
require 'ruby_llm'

RubyLLM.configure do |config|
  config.openrouter_api_key = ENV['OPENROUTER_API_KEY']
end

directory 'extract'
directory 'transform/clean'
directory 'transform/embeddings'

desc 'Prepare input CSV file by querying content store base'
file 'extract/raw.csv' => 'extract' do
  query_file = File.join(File.dirname(__FILE__), 'query.sql')
  output = File.join(File.dirname(__FILE__), 'extract', 'raw.csv')

  sh "govuk-docker up -d content-store-lite"
  sh "docker exec -i govuk-docker-content-store-lite-1 rails db < #{query_file} > #{output}"
  sh "govuk-docker down content-store-lite"
end

def raw_data
  @raw ||= CSV.read('extract/raw.csv', headers: true)
end

def raw_data_ids
  raw_data.map { |row| row['id'] }
end

def strip_tags(s)
  Nokogiri.HTML(s).text.gsub(/\\n\s*/, " ")
end

raw_data_ids.each do |id|
  desc "Prepare file transform/clean/#{id}.json"
  file "transform/clean/#{id}.json" => ['transform/clean', 'extract/raw.csv'] do |f|
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

desc 'Regenerate all files in transform/clean'
task :transform_clean => raw_data_ids.map { |id| "transform/clean/#{id}.json" }

raw_data_ids.each do |id|
  desc "Prepare file transform/embeddings/#{id}.json"
  file "transform/embeddings/#{id}.json" => ['transform/embeddings', "transform/clean/#{id}.json"] do |f|
    puts "Generating #{f.name}"

    input_json = JSON.load_file("transform/clean/#{id}.json")
    text_to_embed = [input_json['title'], input_json['body']].join(' ')

    embedding = RubyLLM.embed(
      text_to_embed,
      provider: 'openrouter',
      model: 'qwen/qwen3-embedding-4b',
      assume_model_exists: true
    )

    File.write(
      f.name,
      JSON.pretty_generate(
        {
          title: input_json['title'],
          vector: embedding.vectors
        }))
  end
end

desc 'Regenerate all files in transform/embeddings'
task :transform_embeddings => raw_data_ids.map { |id| "transform/embeddings/#{id}.json" }

task :setup => ['extract/raw.csv']

task :default do
  Rake::Task['setup'].invoke
  exec('rake', 'transform_embeddings')
end

CLOBBER.include('extract', 'transform')
