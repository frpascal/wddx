#  $Id: wddx_packet.rb 94 2006-12-24 13:05:36Z stefan $
#  Created by Stefan Saasen.
#  Copyright (c) 2006. All rights reserved.

module WDDX
    
  PACKET_VERSION = 1.0
  
  # Resembles a WddxPacket
  # 
  # A WddxPacket has a single data field and a comment (a string)
  # 
  # = Usage        
  #  require 'rubygems' # unless defined otherwise                                                 
  #  require 'open-uri'
  #  require 'wddx'
  #  
  #  packet =  WDDX.load(open("http://wddx.rubyforge.org/wddx.xml")) 
  #  puts packet.class # => WDDX::WddxPacket
  #  puts packet.comment # "Das ist ein Kommentar"
  #  p packet.data # => {"aBoolean"=>true, "anObject"=> ...
  #
  # <b>WddxPackt is not ment to be used directly. You get a WddxPacket using WDDX.load or WDDX.open.</b>
  class WddxPacket
    attr_accessor :comment, :data
    def initialize # :nodoc:
      @data = nil
    end                     
    
    # WDDX Version. Currently "1.0"
    def version; PACKET_VERSION; end   

    # If @data is a hash you can use a shortcut version
    #
    #  packet.data["my_val"] # => ...
    #  packet.my_val # => ...
    def method_missing(sym, *args) # :nodoc:
      if @data.respond_to?(:key?) && @data.key?(sym.to_s)
        return @data[sym.to_s]
      end
      super
    end
    
  end # class WddxPacket
  
end