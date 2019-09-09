# $Id: wddx_serialize.rb 109 2007-04-07 15:29:03Z stefan $
# Author: Stefan Saasen <s@juretta.com>

require 'rubygems'
require 'wddx'

# helper methods
require 'example_helper'

=begin
To serialize Ruby objects different approaches exist.
1. You can use WDDX.dump with the ruby object as argument
2. The core classes (String, Numeric, Array, Hash...) have 
   a "to_wddx" method that can be called directly
3. You can mixin the WDDX module into arbitrary classes to get a to_wddx method in your
   custom classes
=end

# Use WDDX.dump to dump core Ruby objects
print_xml WDDX.dump("klaus tester") # => <wddxPacket version='1.0'>...

print_xml WDDX.dump([:sym, 123, Time.now])

print_xml WDDX.dump({:key => 123})

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# To serialize custom Ruby objects there is only one step necessary.
# You need to define a "to_wddx_properties" method
# which returns an array of properties or methods that should be serialized.
# Then you can use WDDX.dump to serialize an instance of your class.
class Class1
  def initialize(a,b,c); @a, @b, @c = a, b, c; end
  def custom_method; "a: #{@a}, b: #{@b}, c: #{@c}"; end
  
  # serialize the instance variables @a and @c and the method custom_method
  def to_wddx_properties; ["@a", "@c", :custom_method]; end
end

print_xml WDDX.dump(Class1.new(:a, 1, Time.now))

# You can mixin the WDDX module which defines a default "to_wddx_properties" method
# which serializes all instance variables.
class Class2
  include WDDX # defines a default to_wddx_properties method
  def initialize(a,b,c)
    @a, @b, @c = a, b, c
  end
end
# WDDX.dump needs to_wddx_properties to serialize the custom Ruby object.
print_xml WDDX.dump(Class2.new(:class2, 2, Time.now))

# Moreover the WDDX module defines a "to_wddx" method which can be used to 
# serialize the object without using WDDX.dump.
print_xml Class2.new(:class2, 3, Time.now).to_wddx

# The WDDX module can be mixed into existing classes as well.
require 'ostruct'
# To dump every OpenStruct object you would certainly mixin the WDDX modul into
# the OpenStruct class
class OpenStruct
  include WDDX
  # serialize the virtual ostruct properties
  def to_wddx_properties
    @table.keys
  end
end

country_de = OpenStruct.new({ "country" => "Germany", :population => 80_000_000 })
print_xml WDDX.dump(country_de)
# OR because of the mixed in wddx module
print_xml country_de.to_wddx

# change the properties that should be serialized using a singleton method
def country_de.to_wddx_properties
  [:country]
end
print_xml country_de.to_wddx # => only country will be serialized due to to_wddx_properties

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Core ruby classes can be serialized by calling "to_wddx" directly.

# String
print_xml "ruby".to_wddx

# Symbol
print_xml :a_symbol.to_wddx

# true
print_xml true.to_wddx

# false
print_xml false.to_wddx

# Numeric
print_xml 12.to_wddx

# Array
print_xml ["a string", nil, true, false, :a_symbol, [1,2], {:a => "b"}, Time.now, 3.4].to_wddx

# Hash
print_xml({:a => 2}.to_wddx)

# Time
print_xml Time.now.to_wddx

# Nil
print_xml nil.to_wddx

# to_wddx and WDDX.dump yield the same result
["a string", nil, true, false, :a_symbol, [1,2], {:a => "b"}, Time.now, 3.4].each do |var|
  print "#{var.class} Same? -> "
  puts WDDX.dump(var).eql?(var.to_wddx)
end
