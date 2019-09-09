= WDDX

http://wddx.rubyforge.org/

== DESCRIPTION

Ruby API for the WDDX XML interchange format (see http://www.openwddx.org/) 

From http://www.openwddx.org/faq/:
 WDDX is an XML-based technology that enables the exchange of complex data between Web programming languages, 
 creating what some refer to as 'Web syndicate networks'. 
 WDDX consists of a language-independent representation of data based on an XML 1.0 DTD, and a set of 
 modules for a wide variety of languages that use WDDX. 
 WDDX can be used with HTTP, SMTP, POP, FTP and other Internet protocols that support transferring textual data.

WDDX Home: http://www.openwddx.org/

The Ruby WDDX Gem enables easy usage of WDDX in Ruby.

== Author

Copyright (C) 2005, 2006, 2007, 2008 by Stefan Saasen <s-NOSPAM-REMOVE@juretta.com> - http://juretta.com/

== Installation

Just run <tt>[sudo] gem install wddx</tt> to install the WDDX Gem.


== SYNOPSIS

=== Deserialization
You can very easily deserialize WDDX data from a file or from a string.

Simple usage example:
 
 require 'rubygems'
 require 'wddx'        
 # data.xml contains <?xml version="1.0">\
 # <wddxPacket version='1.0'><header><comment>A comment</comment></header><data><string>Klaus Tester</string></data></wddxPacket> 
 wddx = WDDX.load(File.open("data.xml"))
 puts wddx.comment # "A comment"
 puts wddx.data.class # String
 puts wddx.data # "Klaus Tester"
 
WDDX.load accepts a string with xml content, a file object or any object that provides a +read+ method.
 packet =  WDDX.load(open("http://wddx.rubyforge.org/wddx.xml"))
or
 packet =  WDDX.load(File.open("data.xml")) 
or
 packet =  WDDX.load(open("data.xml"))
or
 xml = "<wddxPacket version='1.0'><header/><data><number>123.667</number></data></wddxPacket>"
 packet = WDDX.load(xml)
 puts w.data # => 123.667
 
 xml = <<-EOF 
 <wddxPacket version='1.0'>
 <header/>
 <data>
     <struct>
         <var name='aNull'>
             <null/>
         </var>
         <var name='aString'>
             <string>a string</string>
         </var>
     </struct>
    </data>
  </wddxPacket> 
 EOF
 w = WDDX.load(xml)
 p w.data # => {"aString"=>"a string", "aNull"=>nil}
                                         
If the root element is a +struct+ you can use a shortcut version:
 
 w.data["aString"] # => "a string"

can be written as:

 w.aString # => "a string"


=== Serialization
The core Ruby Classes +Symbol+, +String+, +Numeric+, +true+, +false+, +nil+, +Hash+, +Array+ and +Time+ can be serialized by calling
+to_wddx+.

 require 'wddx'
 "Stefan Saasen".to_wddx        # => "<wddxPacket version='1.0'><header/><data>\
                                #     <string>Stefan Saasen</string></data></wddxPacket>"

 123.667.to_wddx                # => "<wddxPacket version='1.0'><header/><data>\
                                #     <number>123.667</number></data></wddxPacket>"

 Math::PI.to_wddx               # => "<wddxPacket version='1.0'><header/><data>\
                                #   <number>3.14159265358979</number></data></wddxPacket>"

 [1000, "Klaus Tester"].to_wddx # => "<wddxPacket version='1.0'><header/><data>\
                                #   <array length='2'><number>1000</number>\
                                #   <string>Klaus Tester</string></array></data></wddxPacket>"

=== WDDX.dump
You can use WDDX.dump to serialize Ruby objects.
 WDDX.dump("Hallo Welt") # => "<wddxPacket version='1.0'><header/><data><string>Hallo Welt</string></data></wddxPacket>"


Custom Ruby classes can be serialized by adding a +to_wddx_properties+ method (in the style of the YAML library) and calling WDDX.dump.

 class SerializeFromOutside
   def initialize(a,b,c)
     @a, @b, @c = a, b, c
   end
   
   def to_wddx_properties
     ["@a", "@c"]
   end  
 end 
 obj = SerializeFromOutside.new("This is a", "This is b", 123) 
 WDDX.dump(obj) # => "<wddxPacket version='1.0'><header/><data><struct><var name='a'>\
                # <string>This is a</string></var><var name='c'><number>123</number>\
                # </var></struct></data></wddxPacket>"

It is possible to include the WDDX module to get a behaviour similiar to the core Ruby classes.

 class MyObject
   include WDDX
   attr_accessor :name, :value, :price

   def to_wddx_properties
     ["@name", :custom_price]
   end               

   def custom_price
     @price * 1.05
   end
 end

 obj = MyObject.new("Stefan Saasen", 120)
 puts ob.to_wddx
 # => "<wddxPacket version='1.0'><header/><data><struct><var name='name'>\
 # <string>Stefan Saasen</string></var><var name='custom_price'><number>126.0</number>\
 # </var></struct></data></wddxPacket>"     
                                    
== WDDX Data types

WDDX defines some data types which can not be mapped to native ruby classes. WDDX::Binary represents a binary object (which is in fact a BASE64 encoded String). WDDX::RecordSet represents a RecordSet with data rows an column meta information.

== Type mapping
The following table shows the data type mapping WDDX <=> Ruby.
 WDDX Type      Ruby Type
 ---------      ---------------------
 String         String
 Number         Numeric
 Boolean        TrueClass, FalseClass
 Datetime       Time
 Null           nil
 Binary         WDDX::Binary
 Array          Array
 Struct         Hash
 Recordset      WDDX::RecordSet


== Rails Plugin

You can add the wddx gem to your rails application to be able to serialize ActiveRecord objects to WDDX.

In config/environment.rb add:
 require 'wddx'

Example:
 
 ...
 a_ar_obj.to_wddx # => <wddxPacket...


== See

Homepage:: http://rubyforge.org/projects/wddx/
Blog:: http://juretta.com/
Bugtracker:: http://rubyforge.org/tracker/?group_id=2715
WDDX:: http://www.openwddx.org/

== LICENSE:

(The MIT License)

Copyright (c) 2005, 2006, 2007, 2008 by Stefan Saasen <s-NOSPAM-REMOVE@juretta.com> - http://juretta.com/

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
