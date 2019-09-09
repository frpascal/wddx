#!/usr/bin/env ruby
#
#  Created by Stefan Saasen on 2006-12-17.
#  Copyright (c) 2006. All rights reserved.        

require File.dirname(__FILE__) + '/test_helper.rb' 
     

class MyObject
  include WDDX
  attr_accessor :name, :value, :price
  
  def initialize(name, price)
    @name, @price = name, price  
  end
  
  def to_wddx_properties
    ["@name", :custom_price]
  end               

  def custom_price
    @price * 1.05
  end
end

class AnotherObject
  include WDDX
  
  attr_accessor :my_object
  def to_wddx_properties
    ["@my_object"]
  end
end
    
class SerializeFromOutside
  
  def initialize(a,b,c)
    @a, @b, @c = a, b, c
  end
  
  def to_wddx_properties
    ["@a", "@c"]
  end  
  
end

# This is a TestCase containing UnitTests testing what is considered the public API.
# Here you can find usefule information and usage patterns.
class TcWddxPublicApiTest < Test::Unit::TestCase
  
  def test_simple_dump
    assert_equal("<wddxPacket version='1.0'><header/><data><string>Hallo Welt</string></data></wddxPacket>", WDDX.dump("Hallo Welt"))
  end
  
  def test_core_string_to_wddx
    assert_equal("<wddxPacket version='1.0'><header/><data><string>Hallo Welt</string></data></wddxPacket>", "Hallo Welt".to_wddx)
  end
  
  def test_core_number_to_wddx
    assert_equal("<wddxPacket version='1.0'><header/><data><number>10</number></data></wddxPacket>", 10.to_wddx)
    assert_equal("<wddxPacket version='1.0'><header/><data><number>-123</number></data></wddxPacket>", -123.to_wddx)
    assert_equal("<wddxPacket version='1.0'><header/><data><number>3.14159265358979</number></data></wddxPacket>", Math::PI.to_wddx)
  end
  
  def test_core_time_to_wddx
    assert_equal("<wddxPacket version='1.0'><header/><data><dateTime>2000-01-01T20:15:01Z</dateTime></data></wddxPacket>", Time.utc(2000,"jan",1,20,15,1).to_wddx)
  end 
  
  def test_dump
     vars = []
     vars << 23
     vars << Math::PI
     vars << {"key2" => Time.at(946702800).gmtime}
     assert_equal "<wddxPacket version='1.0'><header/><data><array length='3'><number>23</number><number>3.14159265358979</number><struct><var name='key2'><dateTime>2000-01-01T05:00:00Z</dateTime></var></struct></array></data></wddxPacket>", WDDX.dump(vars)
  end
  
  
  def test_load
    wddx = WDDX.load(File.open(FIXTURES + "/doc.1.xml"))
    assert_equal "A comment", wddx.comment
    assert_equal String, wddx.data.class
    assert_equal "Klaus Tester", wddx.data
  end
      
  def test_obj_serialization
    obj = MyObject.new("Stefan Saasen", 120)
    assert_equal "<wddxPacket version='1.0'><header/><data><struct><var name='name'><string>Stefan Saasen</string></var><var name='custom_price'><number>126.0</number></var></struct></data></wddxPacket>", obj.to_wddx    
    
    obj2 = AnotherObject.new
    obj2.my_object = obj
    assert_equal "<wddxPacket version='1.0'><header/><data><struct><var name='my_object'><struct><var name='name'><string>Stefan Saasen</string></var><var name='custom_price'><number>126.0</number></var></struct></var></struct></data></wddxPacket>", obj2.to_wddx                                                 
  end  
  
  
  def test_obj_serialization_without_include
    obj = SerializeFromOutside.new("This is a", "This is b", 123)
    assert_equal "<wddxPacket version='1.0'><header/><data><struct><var name='a'><string>This is a</string></var><var name='c'><number>123</number></var></struct></data></wddxPacket>", WDDX.dump(obj)
  end
  
  
  def test_shortcut_for_struct
    xml = "<wddxPacket version='1.0'><header/><data><struct><var name='name'><string>Stefan</string></var><var name='custom_price'><number>126.0</number></var></struct></data></wddxPacket>"
    packet = WDDX.load(xml)
        
    assert_equal("Stefan", packet.data["name"]) 
    assert_equal(126.0, packet.data["custom_price"])    
    
    assert_equal("Stefan", packet.name) 
    assert_equal(126.0, packet.custom_price) 
  end
  
  
end