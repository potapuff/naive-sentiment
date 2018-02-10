# encoding: utf-8
require './lib/tokenizer'
require './lib/stemmer'
require './lib/utils'

class Analyzer

  attr_accessor :raw, :text, :positive, :negative, :count

  LEVELS = {
      -1.0 => 'red-1',
      -0.5 => 'red-3',
      0.5 => 'green-3',
      1.0 => 'green-1',
  }

  def initialize(text)
    @raw = text.force_encoding(Encoding::UTF_8)
    text = @raw.gsub(/[\n\t\r]+/, ' # ')
    @count = 0
    @positive, @negative = Pair.new, Pair.new

    @text = +''
    dictionary = Analyzer.dictionary
    tokenizer = Tokenizer::WhitespaceTokenizer.new
    tokenizer.tokenize(text).each do |raw_word|
      if raw_word.size > 3
        @count +=1
        word = UkrainianStemmer.new(raw_word).stem_word
        factor = dictionary[word]
        if factor
          (factor >0 ? @positive : @negative).increment! factor
          @text << " <span class='#{LEVELS[factor]}'>#{raw_word}</span> "
          next
        end
      end
      @text << ' ' unless raw_word.match(/[.,]+/)
      @text << raw_word
    end
    @text.gsub!("#", '<p/>')
  end

  def result
    Pair.new(@positive.count+@negative.count, @positive.sum+@negative.sum)
  end

  def self.dictionary
    @@dictionary ||= begin
      file_name = './resources/tone-dict-uk.tsv'
      dict = {}
      IO.read(file_name).force_encoding(Encoding::UTF_8).split("\n").each do |line|
        word, index = line.split("\t")
        steamed = UkrainianStemmer.new(word).stem_word
        dict[steamed] = (index.to_f / 2.0) # normalize -2..2 to -1..1
      end
      dict
    end
  end

end