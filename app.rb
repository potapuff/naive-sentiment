# encoding: utf-8
# frozen_string_literal: true

require 'sinatra'
require 'sanitize'
require 'kramdown'
require './lib/analyzer'
require './lib/utils.rb'

set :environment, :development# :production
set :logging, true
set :show_exceptions, false
set :run, false

configure do
  set :readme, Proc.new {
    text = IO.read("./readme.md").force_encoding(Encoding::UTF_8)
    Kramdown::Document.new(text).to_html
  }
end

get '/' do
  text = IO.read(Dir['./test/**/test4.txt'].rand)
      #IO.read(Dir['./test/**/*.txt'].rand)
  @bind = Analyzer.new(text)
  erb :index, layout: :main
end

post '/' do
  text = params[:text] || ''
  @bind = Analyzer.new(text)
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

  # noinspection RubyStringKeysInHashInspection
  def sanitize text
    Sanitize.fragment(text,
                      :elements => ['span', 'p', 'br'],
                      :attributes => {'span' => ['class']},
                      )
  end

end