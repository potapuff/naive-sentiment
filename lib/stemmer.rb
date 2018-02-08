# encoding: utf-8

=begin
  Port of:
  https://raw.githubusercontent.com/Amice13/ukr_stemmer/master/ukr_stemmer3.py
=end

class UkrainianStemmer

  VOVWL = /аеиоуюяіїє/ # http://uk.wikipedia.org/wiki/Голосний_звук
  PERFECTIVEGROUND = /(ив|ивши|ившись|ыв|ывши|ывшись((?<=[ая])(в|вши|вшись)))$/
  # http://uk.wikipedia.org/wiki/Рефлексивне_дієслово
  REFLEXIVE = /(с[яьи])$/
  # http://uk.wikipedia.org/wiki/Прикметник + http://wapedia.mobi/uk/Прикметник
  AJECTIVE = /(ими|ій|ий|а|е|ова|ове|ів|є|їй|єє|еє|я|ім|ем|им|ім|их|іх|ою|йми|іми|у|ю|ого|ому|ої)$/
  # http://uk.wikipedia.org/wiki/Дієприкметник
  PRACTICIPLE = /(ий|ого|ому|им|ім|а|ій|у|ою|ій|і|их|йми|их)$/
  # http://uk.wikipedia.org/wiki/Дієслово
  VERB = /(сь|ся|ив|ать|ять|у|ю|ав|али|учи|ячи|вши|ши|е|ме|ати|яти|є)$/
  # http://uk.wikipedia.org/wiki/Іменник
  NOUN = /(а|ев|ов|е|ями|ами|еи|и|ей|ой|ий|й|иям|ям|ием|ем|ам|ом|о|у|ах|иях|ях|ы|ь|ию|ью|ю|ия|ья|я|і|ові|ї|ею|єю|ою|є|еві|ем|єм|ів|їв|ю)$/
  RVRE = /[аеиоуюяіїє]/
  DERIVITIONAL = /[^аеиоуюяіїє][аеиоуюяіїє]+[^аеиоуюяіїє]+[аеиоуюяіїє].*(?<=о)сть?$/

  def initialize(word)
    @word = word
    @result = ''
  end

  def ukstemmer_search_preprocess(word)
    word = word.downcase
    word = word.sub("'", "")
    word = word.sub("ё", "е")
    word.sub("ъ", "ї")
  end

  def s(st, reg, to)
    orig = st
    @result = st.sub(reg, to)
    (orig != @result)
  end

  def stem_word
    word = ukstemmer_search_preprocess(@word)
    if !(/[аеиоуюяіїє]/.match(word))
      stem = word
    else
      p = word.index(RVRE)
      start = word[0..p]
      @result = word[(p+1)..-1]
      # Step 1
      unless s(@result, PERFECTIVEGROUND, '')
        s(@result, REFLEXIVE, '')
        if s(@result, AJECTIVE, '')
          s(@result, PRACTICIPLE, '')
        else
          unless s(@result, VERB, '')
            s(@result, NOUN, '')
          end
        end
      end
      # Step 2
      s(@result, 'и$', '')

      # Step 3
      if DERIVITIONAL.match(@result)
        s(@result, 'ость$', '')
      end

      # Step 4
      if s(@result, 'ь$', '')
        s(@result, 'ейше?$', '')
        s(@result, 'нн$', 'н')
      end
      stem = start + @result
    end
    stem
  end
end