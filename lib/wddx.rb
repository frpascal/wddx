#--
# $Id: wddx.rb 115 2007-08-22 21:11:31Z stefan $
#
# Copyright (C) 2005, 2006 by Stefan Saasen <s@juretta.com>
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++                                      
require 'open-uri'
#$:.unshift(File.dirname(__FILE__) + "/wddx") unless $:.include?(File.dirname(__FILE__) + "/wddx") || $:.include?(File.expand_path(File.dirname(__FILE__) + "/wddx"))

Dir[File.join(File.dirname(__FILE__), 'wddx/**/*.rb')].sort.each { |lib| require lib }           

# == Usage
#:include:README.txt
module WDDX
  # class methods
  class << self
    # Reads WDDX-XML from obj. Obj can be a String or every Object that responds to a "read" method (File, open-uri...)
    #  require 'open-uri'
    #  packet = WDDX.load(open("http://wddx.rubyforge.org/wddx.xml"))
    def open(obj, &block)
      if obj.respond_to?(:read)
        return deserialize(obj.read)
      end
      deserialize(obj)
    end
    alias :load :open
    
    # Reads WDDX-XML from the file +filename+.
    def from_file(filename, &block)
      deserialize(open(filename))
    end          
    alias :file :from_file
    
    # Deserialize WDDX-XML to a WDDX::WddxPacket
    #  p = WDDX.deserialize(xml_string)
    #  p.data # => String, Number, Time...
    def deserialize(xml_string)       
      Deserializer::Deserializer.new(xml_string).wddx_packet
    end
    
    # The method dump tries to serialize arbitrary Ruby objects.
    #  print WDDX.dump("Hello world") # => "<wddxPacket version='1.0'><header/><data><string>Hello world</string></data></wddxPacket>" 
    # 
    # You can add a +to_wddx_properties+ method to your class that returns an array of fields an method names (as symbol) that will be
    # serialized as WDDX XML.
    #
    #  class MyObj
    #    def initilize(name, price)
    #      @name, @price = name, price
    #    end
    #    def custom_price; @price * 1.05; end 
    #    
    #    def to_wddx_properties
    #      ["@name", :custom_price]
    #    end
    #  end
    #
    #  WDDX.dump(MyObj.new("Klaus Tester", 123))
    def dump(var)
      s = WDDX::Serializer::Serializer.new
      s.add_var var
      s.to_xml
    end
      
  end # class << self
  
  # The WDDX module can be mixed into arbitrary classes.
  # The method +wddx_serialize+ serializes the instance variables
  # or the instance variables and methods output defined in +to_wddx_properties+
  def wddx_serialize #:nodoc:
    hash = {}
    if self.respond_to?(:to_wddx_properties)
      self.send(:to_wddx_properties).each do |prop|
        if prop.respond_to?(:id2name)
          hash[prop.id2name] = self.send(prop)
        elsif prop =~ /^@[^@]/
          hash[prop.gsub(/@/, "")] = instance_variable_get(prop)
        end
      end
    else
      hash = self.instance_variables.sort.inject({}) {|h, var| h[var.to_s.gsub(/@/, "")] = instance_variable_get(var); h}
    end
    hash.wddx_serialize
  end
  
  # The WDDX module can be mixed into arbitrary classes. 
  # You can call +to_wddx+ to get a WDDX-XML representation of your object.
  #
  #  class MyTest
  #    include WDDX
  #    def initialize(a,b)
  #      @a, @b = a, b
  #    end
  #  end
  #  
  #  t = MyTest.new("Hello world", Time.now)
  #  print t.to_wddx # => "<wddxPacket ..."
  def to_wddx
    s = WDDX::Serializer::Serializer.new 
    s.add_var self
    s.to_xml
  end
  
  # = Binary
  # The binary datatype represents strings (blobs) of binary data. The WDDX 
  # DTD allows for multiple encodings of binary data. In this version only 
  # MIME style base64 encoding is supported by the specification. Optionally,
  # the length of the encoded binary object can be provided as a hint to
  # WDDX deserializers. It can be used to validate the length of the binary
  # object after decoding. It can also be used for efficient allocation of
  # memory during the decoding process.
  class Binary < WddxData
    attr_accessor :bin_data                                          
    
    # Initialize with the raw binary data (to be encoded with Base64)
    def initialize(bin_data = nil)
      @bin_data = bin_data
      @_data = nil
    end                   

    # set binary data
    def encoded_data=(arg)
       @bin_data = arg.unpack( 'm' )[0]
    end
    
    # length of the raw binary data in bytes
    def length
      @bin_data.length
    end       
    alias :size :length
    
    # Returns an Base64 encoded string
    def encode
      return @_data unless @_data.nil?
      @_data = [@bin_data].pack( 'm' ).chomp if @bin_data   
      @_data
    end
    
    # Returns the WDDX XML respresentation
    def wddx_serialize # :nodoc:
      "<binary length='#{self.length}'>#{self.encode}</binary>"
    end
    
    alias :data :bin_data
  end
  
end 

# Add "to_wddx"
[WDDX::Struct, WDDX::Binary, WDDX::RecordSet].each {|clazz| clazz.class_eval { include WDDX::Core } }
