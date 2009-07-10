$KCODE='u'
require 'jcode'
require 'utils'

class Structure
  attr_accessor :structures
  @@structures = []
  def Structure.structures 
    @@structures
  end
  
  def initialize(speech)
    @speech = speech
  end
  
  def render_to_win
    render
  end
  
  def render_to_mac
    render
  end
  
  def render

  end
end

class EmphasisQuote < Structure
  @@structures << self
  def initialize(speech, match)
    super speech
    @head, @text, @tail = match.begin(0), match[1], match.end(0) - 1
  end
  
  def render_to_mac
    @speech[@head] = '[[emph +]]'
    @speech[@tail] = '[[emph -]]'
  end
  
  def render_to_win
    @speech[@head] = '<volume level="100"><pitch middle="1"><rate speed="-2">'
    @speech[@tail] = '</rate></pitch></volume>'
  end
  
  def EmphasisQuote.parse(speech)
    speech.str.scan /"([^"]+)"/ do |match|
      head, text, tail = $~.begin(0), $~[1], $~.end(0) - 1
      if text.split.size < 5
        speech.structures << EmphasisQuote.new(speech, $~)
      end
    end
  end
  
  def to_s
    "EmphasisQuote for #{@text} from #{@head} to #{@tail}"
  end
end

class DashClause < Structure
  @@structures << self
  def initialize(speech, indices)
    super speech
    @indices = indices.compact
  end
  
  def render
    @indices.each do |jndices|
      jndices.each_with_index do |match, index|
        repl = ": "
        repl = ", " if index % 2 == 1
        @speech[match.begin(0)...match.end(0)] = repl
      end
    end
  end

  def DashClause.parse(speech)
    indices = Array.new
    speech.str.each_sentence_with_index do |sentence, index|
      sentence.scan /(\s*)(---?)(\s*)/ do |match|
        indices[index] ||= Array.new
        indices[index] << $~    
      end
    end
    speech.structures << DashClause.new(speech, indices)
  end
  
  def to_s
    "EmphasisQuote for #{@text} from #{@head} to #{@tail}"
  end
end

class DecimalNumber < Structure
  @@structures << self
  def initialize(speech, integer_part, decimal_part, range)
    super(speech)
    @integer_part, @decimal_part, @range = integer_part, decimal_part, range
  end
  
  def render
    dec = @decimal_part.split(//).join(' ')
    @speech[@range] = "#{@integer_part} point #{dec}"
  end
  
  def DecimalNumber.parse(speech)
    speech.str.scan(/([\d]+)\.([\d]+)/) do |match|
      integer_part, decimal_part = speech.str[$~.begin(1)...$~.end(1)], speech.str[$~.begin(2)...$~.end(2)]
      speech.structures << DecimalNumber.new(speech, integer_part, decimal_part, $~.begin(0)...$~.end(0))
      # puts "integer_part #{integer_part}, decimal_part #{decimal_part}"
      # puts match.class
      # puts match
      # puts $~.begin(0)
      # puts $~.end(0)
      # puts $~.begin(1)
      # puts $~.end(1)
      # puts $~.begin(2)
      # puts $~.end(2)
    end
  end
  
end


if __FILE__ == $0
  require 'speech'
  str = "The University of Quebec's OMER 5 sub still holds the record of 8.035 knots  , set in 2007."
  # str = '"foo" bar "baz"'
  speech = Speech.new str
  puts speech.render_to_mac
  
  puts "done!"
end