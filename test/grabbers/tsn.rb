require 'date'
require 'open-uri'
require 'nokogiri'
require 'fileutils'

def range( start_date, end_date)
  array = []
  loop do
    array << start_date
    start_date = start_date + 1
    break if start_date >= end_date
  end
  array
end


def page(url, category, slug)
  dir = "./test/tsn/#{category}/"
  file =  dir + "#{ '%09d' % slug}.txt"
  article = Nokogiri::HTML(open(url))
  body = article.css('article.c-post div.e-content')
  body.css('aside').each {|node| node.remove}
  body.css('div').each {|node| node.remove}
  text = body.inner_text
  return if text.strip.empty?
  FileUtils.mkdir_p(dir)
  IO.write(file, text.gsub(/[\r\n]+/,"\n"))
end

BASE = "https://tsn.ua/"
@slug = 0

range(Date.strptime("01-12-2017", "%d-%m-%Y"), Date.strptime("09-02-2018", "%d-%m-%Y")).each do |date|
  puts "\n#{date}"
  url = BASE+"archive/"+ date.strftime("%Y/%m/%d")
  links = open(url) rescue nil
  unless links #on retrieve fail
    sleep 15
    next
  end
  archive_page = Nokogiri::HTML(links)
  archive_page.css('article.h-entry a.c-post-img-wrap').each do |link|
    article = link['href']
    if article[/#{BASE}(\w+).*/]
      category = $1
      puts "#{@slug + 1 } #{category} - #{article}"
      sleep 1
      page(article, category, @slug += 1) rescue puts "fall"
    end
  end
end


# analyse ant put results to file
require './lib/utils'
require './lib/analyzer'
out = ""
Dir['./test/tsn/**/*.txt'].sort.each do |filename|
  text = IO.read(filename).force_encoding(Encoding::UTF_8).gsub("\r\n",'').gsub("\r\r","\n")
  bind = Analyzer.new(text)
  filename[/tsn\/(\w+)/]
  category = $1
  out << [filename, category,
          bind.count, bind.result,
          bind.positive.count, bind.positive.sum,
          bind.negative.count, bind.negative.sum].join("\t") << "\n"
  print '.'
end

IO.write("tsn.out", out)
puts "."
