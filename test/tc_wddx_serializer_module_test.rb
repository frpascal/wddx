require File.dirname(__FILE__) + '/test_helper.rb'

class MyTestClass
  include WDDX
  attr_accessor :test
  
  def initialize
    @test = "Klaus Tester"
  end
end

class AnotherClass < MyTestClass
  def initialize
    super
    @name = "Stefan Saasen"
  end
end

class MyObject2
  include WDDX
  attr_accessor :name, :value
end

class TcWddxSerializerModuleTest < Test::Unit::TestCase

  def test_include_module
    t = MyTestClass.new
    assert_equal "<wddxPacket version='1.0'><header/><data><struct><var name='test'><string>Klaus Tester</string></var></struct></data></wddxPacket>", t.to_wddx
  end
    
  def test_include_module_subclass
    t = AnotherClass.new
    assert_equal "<wddxPacket version='1.0'><header/><data><struct><var name='name'><string>Stefan Saasen</string></var><var name='test'><string>Klaus Tester</string></var></struct></data></wddxPacket>", t.to_wddx
  end
  
  def test_include_module_2
    obj = MyObject2.new
    obj.name = "Stefan Saasen"
    obj.value = 12
    assert_equal "<wddxPacket version='1.0'><header/><data><struct><var name='name'><string>Stefan Saasen</string></var><var name='value'><number>12</number></var></struct></data></wddxPacket>", obj.to_wddx    
  end
    
  
end