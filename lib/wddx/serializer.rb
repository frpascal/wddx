#  $Id: serializer.rb 109 2007-04-07 15:29:03Z stefan $
#  Created by Stefan Saasen.
#  Copyright (c) 2006. All rights reserved.
            
module WDDX
  # Serialize ruby objects to wddx XML
  module Serializer # :nodoc:
    
    class << self
      
      # Serialize a single object to wddx
      def serialize_var(var)
        if var.respond_to?(:wddx_serialize)  
          return var.wddx_serialize 
        elsif var.respond_to?(:to_wddx_properties)
          hash = {}
          var.send(:to_wddx_properties).each do |prop|
            if prop.respond_to?(:id2name)
              hash[prop.id2name] = var.send(prop)
            elsif prop =~ /^@/
              hash[prop.gsub(/@/, "")] = var.instance_variable_get(prop)
            end
          end 
          return hash.wddx_serialize
        end
      end # serialize_var
      
    end # class << self
    
    class Serializer # :nodoc:
      # 
      def initialize(indent = false)
         @data = [] # serialized data
         @comment = nil
         @_xml = [] # result cache
      end       
      
      # Add a comment to the WddXPacket.
      #
      #  wddx.add_comment "Das ist ein Kommentar"
      #  =>
      #  <wddxPacket version='1.0'>
      #    <header>
      #      <comment>
      #        Das ist ein Kommentar
      #      </comment>
      #    </header>
      def add_comment(comment)
        @comment = comment
      end
      
      # Add Ruby objects to be serialised as WDDX Xml.
      def add_var(var)
        @data << WDDX::Serializer.serialize_var(var)
        @_xml = [] # reset the result cache
      end
      
      # Create the WDDX Xml Packet. 
      #--
      # Due to performance considerations the XML is built the easy way (could have user REXML instead).
      def to_xml     
        return @_xml unless @_xml.empty?
        @_xml << "<wddxPacket version='1.0'>"
        if @comment.nil?
          @_xml << "<header/>"
        else
          @_xml << "<header><comment>#{@comment}</comment></header>"
        end
        @_xml << "<data>" 
        if @data.size.eql?(1)
          @_xml << @data       
        else 
          @_xml << "<array length='#{@data.size}'>"
          @_xml << @data
          @_xml << "</array>"
        end                
        @_xml << "</data></wddxPacket>"
        @_xml = @_xml.join('')
        @_xml
      end
      alias :to_s :to_xml
      alias :inspect :to_xml
      
    end # class Serializer
  end # module Serializer
end # module WDDX