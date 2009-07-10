require 'osx/cocoa'
require 'net/http'
require 'uri'
SpeechServerURL = 'http://jackie.cs.northwestern.edu:8080/GenerateTestSpeech'
Kate = "NeoSpeech Kate 16k"


module SpeechClient
  def SpeechClient.speak_text(text)
    res = Net::HTTP.post_form(URI.parse(SpeechServerURL), {'text'=>text, 'voice'=>Kate, 'redirect'=>'0'})
    url = res.body
    puts url

    sound = OSX::NSSound.alloc.initWithContentsOfURL_byReference_(OSX::NSURL.URLWithString(url), false)
    sound.play
    sleep(sound.duration + 0.1) #who needs delegates?!
    sound.release
  end
  
end

if __FILE__ == $0
  SpeechClient.speak_text("Modules work!")
end