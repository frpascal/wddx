#  $Id: core_ext.rb 109 2007-04-07 15:29:03Z stefan $
#  Created by Stefan Saasen.
#  Copyright (c) 2006. All rights reserved.

module WDDX
  module Core # :nodoc:
    def to_wddx
      WDDX.dump(self)
    end
  end

  def xml_escape(s)
    s.to_s.
      gsub(/&/, "&amp;").
      gsub(/\"/, "&quot;").
      gsub(/>/, "&gt;").
      gsub(/</, "&lt;").
      gsub(/'/, "&apos;")
  end
  module_function :xml_escape
end

[Symbol, String, Numeric, TrueClass, FalseClass, NilClass, Time, Array, Hash].each {|clazz| clazz.class_eval { include WDDX::Core } }

class Symbol #:nodoc:
  def wddx_serialize
    self.to_s.wddx_serialize
  end
end

class String #:nodoc:
  def wddx_serialize
    # self.unpack("c*").collect {|c| c < 30 ? "<char code='#{c}'/>" : c.chr}.join('')
    "<string>#{WDDX.xml_escape(self).gsub(/\n/, "<char code='0A'/>").gsub(/\r/, "<char code='0D'/>")}</string>"
  end
end

class Numeric #:nodoc:
  def wddx_serialize
    "<number>#{self}</number>"
  end
end

class Bignum #:nodoc:
  def wddx_serialize
    self.to_f.wddx_serialize
  end
end

class TrueClass #:nodoc:
  def wddx_serialize
    '<boolean value=\'true\'/>'
  end
end

class FalseClass #:nodoc:
  def wddx_serialize
    '<boolean value=\'false\'/>'
  end
end

class NilClass #:nodoc:
  def wddx_serialize
    '<null/>'
  end
end

class Time #:nodoc: 
  def wddx_serialize
    "<dateTime>#{self.iso8601}</dateTime>"
  end
end

class Array # :nodoc:
  def wddx_serialize()
    serialized_values = self.collect {|v| WDDX::Serializer.serialize_var(v) }
    xml = "<array length='#{serialized_values.size}'>"
    xml << serialized_values.join("")
    xml << "</array>"
    xml
  end
end

class Hash # :nodoc:
  def wddx_serialize
    xml = ["<struct>"]
    self.each do |k,v|
      xml << "<var name='#{WDDX.xml_escape(k)}'>"
      xml << WDDX::Serializer.serialize_var(v)
      xml << "</var>"
    end
    xml << "</struct>"
    xml.join("")
  end
end