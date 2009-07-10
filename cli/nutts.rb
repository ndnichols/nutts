#!/usr/bin/env ruby
require 'erb'

def speak_text(text, html=true)
  output_filename = File.join(File.dirname(__FILE__), 'output.rhtml')
  escaped_text = text.gsub(/"/, '\"')
  output = `/Users/nate/nutts "#{escaped_text}"`
  if html
    template = ERB.new open(output_filename).read
    template.result binding
  else
    output
  end
end

if __FILE__ == $0
  text = ARGV[0]
  text ||= "The titular protagonist is a young boy born with horns [[pbas +10]]."#{}" whom his village considers a bad omen.  How about that?"
  puts speak_text(text, false)
end

