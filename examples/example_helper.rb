# $Id: example_helper.rb 109 2007-04-07 15:29:03Z stefan $
# Author: Stefan Saasen <s@juretta.com>

# only required to pretty print the XML examples
require 'rexml/document'

# Print XML example
def print_xml(xml)
  # Print method call
  f = caller.first.split(":")
  puts IO.readlines(f.first)[f.last.to_i-1].gsub(/(print_xml|\n|#(.*)$)/, "").strip + ": "
  # Print XML
  REXML::Document.new(xml).write($stdout, 2)
  # Print separator
  puts "\n" + ("~" * 60) + "\n"
end

# Print example
def print_e(var)
  # Print method call
  f = caller.first.split(":")
  print IO.readlines(f.first)[f.last.to_i-1].gsub(/(print_e|\n|#(.*)$)/, "").strip + ": "
  # Print var
  puts var
  # Print separator
  puts ("~" * 60) + "\n"
end