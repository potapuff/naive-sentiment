# encoding: utf-8
# frozen_string_literal: true

require 'sinatra'
require 'tokenizer'
require 'sanitize'
require './lib/stemmer.rb' # ~15% better to require 'lingua/stemmer'
require './lib/utils.rb'

set :environment, :production
set :logging, true
set :show_exceptions, false
set :run, false

configure do
  set :dictionary, Proc.new {
    file_name = './resources/tone-dict-uk.tsv'
    dict = {}
    IO.read(file_name).force_encoding(Encoding::UTF_8).split("\n").each do |line|
      word, index = line.split("\t")
      steamed = UkrainianStemmer.new(word).stem_word
      dict[steamed] = (index.to_f / 2.0) # normalize -2..2 to -1..1
    end
    dict
  }
end

get '/' do
  text = IO.read(Dir['./test/**/*.txt'].rand)
  @bind = analyze(text.force_encoding(Encoding::UTF_8))
  erb :index, layout: :main
end

post '/' do
  raw = params[:text] || ''
  @bind = analyze(raw)
  erb :index, layout: :main
end

error do
  status 500
  e = env['sinatra.error']
  "Application error\n#{e}\n#{e.backtrace.join("\n")}"
end

helpers do

  def h(text)
    Rack::Utils.escape_html(text)
  end

  def sanitize text
    Sanitize.fragment(text,
                      :elements => ['span', 'p', 'br'],
                      :attributes => {'span' => ['class']},
                      )
  end

  LEVELS = {
      -1 => 'red-1',
      -0.5 => 'red-4',
      0.5 => 'green-4',
      1 => 'green-1',
  }

  def level(value)
    LEVELS[value]
  end

end

private

def analyze(resource)
  out = +''
  count, sum = 0, 0
  dictionary = settings.dictionary
  tokenizer = Tokenizer::WhitespaceTokenizer.new
  tokenizer.tokenize(resource.gsub(/[\n\t\r]+/, ' # ')).each do |raw_word|
    if raw_word.size > 3
      word = UkrainianStemmer.new(raw_word).stem_word
      factor = dictionary[word]
      if factor
        sum += factor
        count += 1
        out << "<span class='#{level(factor)}'>#{raw_word}</span> "
        next
      end
    end
    out << raw_word
    out << ' '
  end
  out.gsub!("#", '<p/>')
  {:raw => resource, :text => out, :count => count, :sum => sum}
end