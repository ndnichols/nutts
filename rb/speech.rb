$KCODE='u'
require 'jcode'
require 'structures'

class Speech
  attr_reader :str, :structures
  attr_accessor :offsets
  def initialize(original_str, *structure_classes)
    @original_str = original_str.dup
    @sanitized_str = sanitize @original_str
    @structure_classes = structure_classes #allows you to constrain structures while debugging
    @structures = Array.new
    reset
    parse
  end
  
  def reset
    @str = @sanitized_str.dup
    @offsets = Array.new
  end
  
  def parse
    if @structure_classes.empty?
      Structure.structures.each { |struct| struct.parse self }
    else
      @structure_classes.each { |struct| struct.parse self }
    end
  end
  
  def fix_index(orig_index)
    last_index = orig_index
    @offsets.each_with_index do |offset, index|
      # puts "index is #{index}, last_index"
      break if index >= last_index
      if offset
        orig_index += offset
        last_index += offset
      end
    end
    orig_index
  end
  
  def []=(*args)
    rhs = args.pop
    case args.size
    when 1
      case args[0]
      when Integer
        index = fix_index(args[0])
        @str[index] = rhs
        offset = rhs.length - 1
      when Range
        head, tail = fix_index(args[0].begin), fix_index(args[0].end)
        # puts "head is #{head}, tail is #{tail}"
        index = head
        if args[0].exclude_end?
          @str[head...tail] = rhs
          offset = rhs.length - (tail - head)
        else
          @str[head..tail] = rhs
          offset = rhs.length - (tail - head + 1)
        end
      else
        raise ArgumentError, "Can't access a #{ args[0].class }" 
      end
    when 2
      index, length = fix_index(args[0]), args[1]
      @str[index, length] = rhs
      offset = rhs.length - length
    end
    # puts "Offset[index] is #{@offsets[index]}, offset is #{offset}"
    @offsets[index] = (@offsets[index] or 0) + offset
  end
  
  def sanitize(s)
    ret = s.dup
    ret.gsub!(/\xE2\x80\x99|\xCA\xBC/, "'") #two different fancy apostrophes
    ret.gsub!(/\xE2\x80\x94|\xE2\x80\x93/, "--") #em- and en-dash
    ret
  end
  
  def render_to_mac
    reset
    @structures.each do |struct|
      struct.render_to_mac
    end
    @str
  end
  
  def render_to_win
    reset
    @structures.each do |struct|
      struct.render_to_win
    end
    @str[0, 0] = '<volume level="50">'
    @str << '</volume>'
    @str
  end
end

if __FILE__ == $0
  str = "Truth be told, the game is \"big\" -- Doom Resurrection could easily be ported to gaming-specific handhelds -- though it weighs in under 100 MB."
  speech = Speech.new str
  puts speech.render_to_mac
  puts speech.render_to_win
  puts "done!"
end