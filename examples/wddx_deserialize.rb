# $Id: wddx_deserialize.rb 109 2007-04-07 15:29:03Z stefan $
# Author: Stefan Saasen <s@juretta.com>

require 'rubygems' # unless defined otherwise
require 'wddx'
                 
=begin
To deserialize a WDDX-Packet (XML) you need to use the WDDX.load method.
WDDX.load accepts objects that respond to a :read method.
Examples are String, File or OpenUri objects.
=end                 

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~                 
require 'example_helper'                
require 'open-uri'                 
require 'pp' 

# Use open-uri to open a remote file
begin
  packet =  WDDX.load(open("http://wddx.rubyforge.org/wddx.xml")) 
  puts packet.class
  puts packet.comment # "A comment"
  pp packet.data # serialized data   
                        
  puts "-- " * 24
  
  puts packet.data["aNumber"]
  puts packet.aNumber
rescue => e
  $stderr.puts e.message
end

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

xml =<<EOX
<wddxPacket version='1.0'>
      <header/>
      <data>
        <array length='9'>
          <string>a string</string>
          <null/>
          <boolean value='true'/>
          <boolean value='false'/>
          <string>a_symbol</string>
          <array length='2'>
            <number>1</number>
            <number>2</number>
          </array>
          <struct>
            <var name='a'>
              <string>b</string>
            </var>
          </struct>
          <dateTime>2007-04-01T12:19:34+02:00</dateTime>
          <number>3.4</number>
        </array>
      </data>
    </wddxPacket>
EOX

wddx = WDDX.load xml
# wddx.data contains the wddx data (in this case an array)
print_e wddx.data.class # => Array
print_e wddx.data[0] # => "a string"
print_e wddx.data[0].class # => String

print_e wddx.data[6].class # => Hash
print_e wddx.data[6]["a"] # => "b"

print_e wddx.data[7].class # => Time

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
xml =<<EOX
<wddxPacket version='1.0'>
      <header/>
      <data>
        <struct>
          <var name='country'>
            <string>New Zealand</string>
          </var>
          <var name='population'>
            <number>4000000</number>
          </var>
        </struct>
      </data>
    </wddxPacket>
EOX

wddx = WDDX.load xml
print_e wddx.data.class # => Hash

print_e wddx.data["country"] # => "New Zealand"
# To access a hash value you can use the key as method name on the wddx object.
print_e wddx.country # => "New Zealand"
print_e wddx.population # => 4000000

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Deserialize the xml that comes with this file
# wddx.data contains the single string value "Klaus Tester"
wddx = WDDX.load(DATA) # => DATA supports a :read method and can be used directly.
print_e wddx.data # => Klaus Tester
print_e wddx.comment # => "A comment"
__END__
<wddxPacket version='1.0'>
  <header>
    <comment>A comment</comment>
  </header>
  <data><string>Klaus Tester</string></data>
</wddxPacket>