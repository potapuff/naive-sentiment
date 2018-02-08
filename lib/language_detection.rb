# encoding: utf-8

=begin
 LanguageDetection.language("Юхим Їв юшку") => :uk
 LanguageDetection.language("Петр жевал конфеты") => :ru

=end

class LanguageDetection

  DICTIONARY =
  {   :uk => /[iІїЇєЄ]/,
      :ru => /[ыЫэЭъЪ]/}


  def self.language(string)
    rule = DICTIONARY.to_a.detect{|rule| string.match(rule[1])}
    rule && rule[0]
  end

  def self.method_missing(name, *args, &_block)
    key = DICTIONARY.keys.detect{|x| x.to_s+'?' == name.to_s}
    if key
      return !!(args[0]||'').match(DICTIONARY[key])
    end
    raise ArgumentError.new("Method #{name} doesn't exist")
  end

end
