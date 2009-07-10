module Words
  def self.is_word?(word, case_sensitive=true)
    if case_sensitive
      @@words.include? word
    else
      @@lowercase_words.include? word.downcase
    end
  end
  @@words = []
  open('/Users/nate/Programming/newsatseven/nutts/rb/2of12inf.txt').each { |line|   @@words << line.chomp }
  @@lowercase_words = @@words.map { |word| word.downcase }
end

def should_split_on(word)
  if word =~ /^[A-Z]/
    Words.is_word?(word, false)
  else
    true
  end
end

def split_sentences(text)
  ret = []
  last_index = 0
  text.scan(/[\?\!\.]"?\s+[A-Z0-9"]/) do |match|
    orig_match = $~
    prev_word = text[text.rindex(/[\s^]/, orig_match.begin(0))...orig_match.begin(0)].strip
    if should_split_on prev_word
      ret << text[last_index..orig_match.begin(0)]
      last_index = orig_match.end(0) - 1
    end
  end
  ret << text[last_index..-1]
  ret
end


class String
  def each_sentence
    split_sentences(self).each { |sentence| yield sentence }
  end
  def each_sentence_with_index
    split_sentences(self).each_with_index { |sentence, index| yield sentence, index }
  end
end





if __FILE__ == $0
s = <<HERE
The concept of Free: The Past And Future Of A Radical Price—that the lowly giveaway is an economic cornerstone for the digital age—has already been profitable for Chris Anderson, not least in the transformation of a Wired cover story available at no charge online to the $26.99 book that bears his name. That’s probably why the Wired editor and author of The Long Tail isn’t more curious about the long-term implications of shrinking markets and consumer expectations; his economically irresponsible ideas are someone else’s problem.

Anderson tells pithy, incomplete examples of success through free product and services giveaways, from Linux to Radiohead’s In Rainbows; he seasons those with a sprinkle of behavioral studies showing conclusively that people like free stuff. According to Anderson, Free (used as a capitalized noun throughout, as in “Today’s Free is full of apparent contradictions”) is a market force that relentlessly drives prices down, but content-creators can use it to their benefit as long as they acknowledge that information that can be cheaply replicated will be, and its handmaiden technology will continue to improve. 

Anderson proves he isn’t really interested in helping businesses implement Free, or understanding why it doesn’t work for everyone as he takes the leap from the few to the many. If an upstart video-sharing service can’t perform as well as YouTube by providing bandwidth at a loss, it’s due to “poverty of imagination and intolerance for possible failure,” not lack of access to the estimated $470 million Google will spend on YouTube this year without ever turning a profit. Anderson argues that the plummeting price of bandwidth is what lets Google offer YouTube’s services at no charge, but mathematically speaking, moving toward Free is not the same as becoming free by moving the price point.

In a race to the bottom, quality doesn’t matter anymore, whether it’s The Encyclopedia Britannica taking a hit from Encarta in the ’90s or Encarta being nudged aside by Wikipedia now. Given the charges levied against Anderson for quoting large sections of Wikipedia in Free without attribution, an act he first claimed was a “mistake” and then an inability to decide on citation format, it seems the wages of Free are misplaced entitlement, though that practice isn’t listed in the end-of-book section “Fifty Business Models Built On Free.” Piracy, says Anderson, is also the fault of content-creators, who should “simply accept” their role of producing for reasons other than profit, or seek their fortunes elsewhere. Perhaps he wouldn’t be so smug if someone else decided his work was worth as much.
HERE
# split_sentences(s).each { |sentence| puts sentence}
s.each_sentence_with_index{ |sent, index| puts sent}

end