#  $Id: deserializer.rb 94 2006-12-24 13:05:36Z stefan $
#  Created by Stefan Saasen.
#  Copyright (c) 2006. All rights reserved.
 
require 'open-uri'
require 'rexml/document'
require 'rexml/streamlistener'
require File.dirname(__FILE__) + '/wddx_packet'
             
module WDDX
  module Deserializer # :nodoc:                       
    
    class Deserializer # :nodoc:    
      attr_reader :wddx_packet
      def initialize(xml_string)
        listener = Listener.new
        parser = REXML::Parsers::StreamParser.new(xml_string, listener)
        parser.parse
        @wddx_packet = listener.wddx_packet
      end
    end
    
    class Listener #:nodoc:
      include REXML::StreamListener       
      attr_reader :wddx_packet
      
      def initialize
        @wddx_packet = WddxPacket.new
        @stack = []
        @stack <<  Node.new("Root")
        @text = ""
      end
      
      def text(text)
        @text << text.dup #unless text.strip.empty?
      end
      
      def tag_start(name, attributes)
        node = Node.new(name, attributes)
        parent = @stack.last
        parent.children << node
        @stack << node       
      end

      def tag_end(name)
        case name.downcase
          when "comment"
            @wddx_packet.comment = @text.strip
          when "data"
            @wddx_packet.data = @current_node.to_ruby
          when "char" # empty tag
            char = @stack.pop
            @text << eval("0x"+char.attributes["code"]).chr
            return          
        end                                               
        @current_node = @stack.pop
        @current_node.text = @text.strip        
        @text = ""
      end
    end # class Listener    
    
    class Node #:nodoc:
      attr_reader :name, :attributes
      attr_accessor :children, :text
      def initialize(type, attributes = {})   
        raise ArgumentError, "Type is neccessary!" if type.nil?
        @children = []
        @attributes, @type = attributes, type
      end

      def has_children?
         !@children.empty?
      end 
      
      def to_ruby
         return case @type.downcase
           when "string"
             @text
           when "binary"
            bin = Binary.new
            bin.encoded_data = @text
            bin
           when "array", "field"
             @children.collect {|c| c.to_ruby }
           when "struct"
             @children.inject({}) {|mem, c| var = c.to_ruby; mem[var.key] = var.value; mem}                       
           when "var"
             WDDX::Var.new(@attributes["name"], @children.first.to_ruby)
           when "null"
             nil     
           when "number"
             (@text =~ /\./ ) ? @text.to_f : @text.to_i
           when "boolean"
             @attributes["value"].eql?("true")
           #  Date-time values-
           #  Date-time values are encoded according to the full form of ISO8601,
           #  e.g., 1998-9-15T09:05:32+4:0. Note that single-digit values for months,
           #  days, hours, minutes, or seconds do not need to be zero-prefixed. 
           #  While timezone information is optional, it must be successfully parsed
           #  and used to convert to local date-time values. Efforts should me made 
           #  to ensure that the internal representation of date-time values does not 
           #  suffer from Y2K problems and covers a sufficient range of dates. In 
           #  particular, years must always be represented with four digits.
           when "datetime"
             Time.xmlschema(@text) rescue Time.parse(@text)
           when "recordset"
             rs = WDDX::RecordSet.new(@attributes['fieldNames'].split(","))
             elems = []
             @children.collect{|col| elems << col.children }
             elems.transpose.each do |row|
               rs << row.collect {|c| c.to_ruby }
             end # .flatten.collect{|c| c.to_ruby }
             rs
           else
             raise RuntimeError, "#{type} not implemented!"     
             #"Missing -> #{@type}"
         end
      end
     
    end
  end        
  
end    


if __FILE__ == $0
  p WDDX::Deserializer::Deserializer.new(DATA.read).wddx_packet.data   
end

__END__
<?xml version="1.0"?><wddxPacket version='1.0'><header/><data><string>A</string></data></wddxPacket>
