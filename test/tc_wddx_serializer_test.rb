#  $Id: tc_wddx_serializer_test.rb 109 2007-04-07 15:29:03Z stefan $
#  Created by Stefan Saasen.
#  Copyright (c) 2006. All rights reserved.

require File.dirname(__FILE__) + '/test_helper.rb'

class CustomClass
  attr_accessor :name
  def initialize(counter, name)
    @counter, @name = counter, name
  end
  
  def to_s
    "#{@counter}##{@name}"
  end
  
  def to_wddx_properties
    ["@name", :to_s]
  end
end


class TcWddxSerializerTest < Test::Unit::TestCase

  def setup; super; end
  def teardown; super; end

=begin
  - aNull which is a null value,
  - aString which is the string 'a string',
  - aNumber which is the number -12.456,
  - aDateTime which is the date-time value June 12, 1998 4:32:12am,
  - aBoolean which is the boolean value true,
  - anArray which is an array of two elements (10 and 'second element'),
  - aBinary which contains 8 bytes of binary data encoded in base64,
  - anObject which is a structure with two properties s and n, and
  - aRecordset which is a recordset of two rows with fields NAME and AGE.  
=end
  # Test Basic data Types                                              
  def test_bdt_null
    xml = "<wddxPacket version='1.0'><header/><data><null/></data></wddxPacket>"
    wddx = WDDX::Serializer::Serializer.new
    wddx.add_var nil
    assert_equal xml, wddx.to_xml
  end
  
  def test_bdt_string
    xml = "<wddxPacket version='1.0'><header/><data><string>Hallo Ruby</string></data></wddxPacket>"
    wddx = WDDX::Serializer::Serializer.new
    wddx.add_var "Hallo Ruby"
    assert_equal xml, wddx.to_xml
  end
  
  def test_bdt_number
    xml = "<wddxPacket version='1.0'><header/><data><number>123</number></data></wddxPacket>"
    wddx = WDDX::Serializer::Serializer.new
    wddx.add_var 123
    assert_equal xml, wddx.to_xml    
    
    xml = "<wddxPacket version='1.0'><header/><data><number>9.31231</number></data></wddxPacket>"
    wddx = WDDX::Serializer::Serializer.new
    wddx.add_var 9.31231
    assert_equal xml, wddx.to_xml
    
    xml = "<wddxPacket version='1.0'><header/><data><number>-1231.23</number></data></wddxPacket>"
    wddx = WDDX::Serializer::Serializer.new
    wddx.add_var(-1231.23)
    assert_equal xml, wddx.to_xml     
     
    xml = "<wddxPacket version='1.0'><header/><data><number>9.72398472938473e+24</number></data></wddxPacket>"
    wddx = WDDX::Serializer::Serializer.new
    wddx.add_var 9723984729384729849231231
    assert_equal xml, wddx.to_xml      
  end
  
  def test_bdt_datetime
    xml = "<wddxPacket version='1.0'><header/><data><number>123</number></data></wddxPacket>"
    wddx = WDDX::Serializer::Serializer.new
    wddx.add_var 123
    assert_equal xml, wddx.to_xml
  end
  
  def test_bdt_boolean
    xml = "<wddxPacket version='1.0'><header/><data><boolean value='true'/></data></wddxPacket>"
    wddx = WDDX::Serializer::Serializer.new
    wddx.add_var true
    assert_equal xml, wddx.to_xml      
    
    xml = "<wddxPacket version='1.0'><header/><data><boolean value='false'/></data></wddxPacket>"
    wddx = WDDX::Serializer::Serializer.new
    wddx.add_var false
    assert_equal xml, wddx.to_xml    
  end
  
  def test_bdt_array
    xml = "<wddxPacket version='1.0'><header/><data><array length='0'></array></data></wddxPacket>"
    wddx = WDDX::Serializer::Serializer.new
    wddx.add_var []
    assert_equal xml, wddx.to_xml      
    
    xml = "<wddxPacket version='1.0'><header/><data><array length='3'><string>Hallo</string><string>Ruby</string><string>Welt</string></array></data></wddxPacket>"
    wddx = WDDX::Serializer::Serializer.new
    wddx.add_var %w(Hallo Ruby Welt)
    assert_equal xml, wddx.to_xml                  
        
    xml = "<wddxPacket version='1.0'><header/><data><array length='3'><array length='3'><string>Hallo</string><string>Ruby</string><string>Welt</string></array><array length='3'><string>Hallo</string><string>Ruby</string><string>Welt</string></array><array length='3'><string>Hallo</string><string>Ruby</string><string>Welt</string></array></array></data></wddxPacket>"
    wddx = WDDX::Serializer::Serializer.new
    wddx.add_var [%w(Hallo Ruby Welt), %w(Hallo Ruby Welt), %w(Hallo Ruby Welt)]
    assert_equal xml, wddx.to_xml    
    
    xml = "<wddxPacket version='1.0'><header/><data><array length='3'><array length='1'><array length='1'><array length='1'><number>1</number></array></array></array><array length='1'><number>2</number></array><array length='1'><number>3</number></array></array></data></wddxPacket>"
    wddx = WDDX::Serializer::Serializer.new
    wddx.add_var [[[[1]]],[2],[3]]
    assert_equal xml, wddx.to_xml    
  end
  
  def test_bdt_binary
    xml = "<wddxPacket version='1.0'><header/><data><binary length='19'>U2VuZCByZWluZm9yY2VtZW50cw==</binary></data></wddxPacket>"
    wddx = WDDX::Serializer::Serializer.new
    wddx.add_var WDDX::Binary.new("Send reinforcements")
    assert_equal xml, wddx.to_xml
    
    xml = "<wddxPacket version='1.0'><header/><data><binary length='19'>U2VuZCByZWluZm9yY2VtZW50cw==</binary></data></wddxPacket>"
    wddx = WDDX::Serializer::Serializer.new
    wddx.add_var WDDX::Binary.new("Send reinforcements")
    assert_equal xml, wddx.to_xml         
    
    xml = "<wddxPacket version='1.0'><header/><data><binary length='19'>U2VuZCByZWluZm9yY2VtZW50cw==</binary></data></wddxPacket>"
    wddx = WDDX::Serializer::Serializer.new
    bin = WDDX::Binary.new
    bin.bin_data = "Send reinforcements"
    wddx.add_var bin
    assert_equal xml, wddx.to_xml
  end
  
  def test_bdt_object
    # Missing: include WddxSerializable Module to serialize arbitrary Objects
  end
  
  def test_bdt_recordset
    xml = "<wddxPacket version='1.0'><header/><data><recordset rowCount='2' fieldNames='NAME,AGE'><field name='NAME'><string>John Doe</string><string>Jane Doe</string></field><field name='AGE'><number>34</number><number>31</number></field></recordset></data></wddxPacket>"
    wddx = WDDX::Serializer::Serializer.new
    wddx.add_var WDDX::RecordSet.new(['NAME', 'AGE'], [["John Doe", 34], ["Jane Doe", 31]])
    assert_equal xml, wddx.to_xml    
    
    xml = "<wddxPacket version='1.0'><header/><data><recordset rowCount='3' fieldNames='NAME,age'><field name='NAME'><string>John Doe</string><string>Jane Doe</string><string>Stefan Saasen</string></field><field name='age'><number>34</number><number>31</number><number>29</number></field></recordset></data></wddxPacket>"
    wddx = WDDX::Serializer::Serializer.new
    wddx.add_var WDDX::RecordSet.new(['NAME', 'age'], [["John Doe", 34], ["Jane Doe", 31], ["Stefan Saasen", 29]])
    assert_equal xml, wddx.to_xml    
  end 
  
  
  def test_bdt_recordset2
    rows = []
    rows << [6, "MacBook Pro", 2000]
    rows << [10, "MacPro", 2200]
    rs = WDDX::RecordSet.new(["qty", "name", "price"], rows)
    assert_equal "<recordset rowCount='2' fieldNames='qty,name,price'><field name='qty'><number>6</number><number>10</number></field><field name='name'><string>MacBook Pro</string><string>MacPro</string></field><field name='price'><number>2000</number><number>2200</number></field></recordset>", rs.wddx_serialize
    wddx_packet = "<wddxPacket version='1.0'><header/><data><recordset rowCount='2' fieldNames='qty,name,price'><field name='qty'><number>6</number><number>10</number></field><field name='name'><string>MacBook Pro</string><string>MacPro</string></field><field name='price'><number>2000</number><number>2200</number></field></recordset></data></wddxPacket>" 
    assert_equal wddx_packet, WDDX.dump(rs)
    assert_equal wddx_packet, rs.to_wddx
  end
  
  def test_add_var
    xml = "<wddxPacket version='1.0'><header/><data><array length='0'></array></data></wddxPacket>"
    wddx = WDDX::Serializer::Serializer.new
    wddx.add_var []
    assert_equal xml, wddx.to_xml
  end

  def test_ruby_hash
    xml = "<wddxPacket version='1.0'><header/><data><struct><var name='key1'><string>wert</string></var></struct></data></wddxPacket>"
    wddx = WDDX::Serializer::Serializer.new
    wddx.add_var({"key1" => "wert"})
    assert_equal xml, wddx.to_xml
  end
  
  def test_serialize_simple
     wddx = "<wddxPacket version='1.0'><header><comment>Ruby rules!</comment></header><data><struct><var name='pi'><number>3.1415926</number></var><var name='cities'><array length='3'><string>Austin</string><string>Novato</string><string>Seattle</string></array></var></struct></data></wddxPacket>"
     
     @wddx = WDDX::Serializer::Serializer.new
     @wddx.add_comment "Ruby rules!"
     struct = WDDX::Struct.new
     struct["pi"] = 3.1415926
     struct["cities"] = ["Austin", "Novato", "Seattle"]
     
     @wddx.add_var struct
     assert_equal wddx, @wddx.to_xml
  end

  # Bugfix -> serialize control characters
  def test_serialize_all
     xml = "<wddxPacket version='1.0'><header/><data><array length='8'><string>This is array element #1</string><string>This is array element #2</string><string>This is array element #3</string><string>Some special characters, e.g., control characters <char code='0A'/><char code='0D'/>,pre-defined entities &lt;&amp;&gt;</string><struct><var name='B'><string>b</string></var><var name='A'><string>a</string></var></struct><string>true</string><number>-12.456</number><dateTime>2000-01-01T05:00:00Z</dateTime></array></data></wddxPacket>"
     wddx = WDDX::Serializer::Serializer.new
     struct = WDDX::Struct.new
     struct.put("B", "b")
     struct.put("A", "a")
     
     array = ["This is array element #1", "This is array element #2", "This is array element #3", "Some special characters, e.g., " +
                     "control characters " +
                     "\n\r," + 
                     "pre-defined entities <&>", struct, "true", -12.456, Time.at(946702800).gmtime]
     wddx.add_var array  
     assert_equal xml, wddx.to_xml     
  end
  
  # Bugifx -> serialize control characters \n und \r
  # 
  # End-of-line characters have platform and programming language specific 
  # representations. Different application environments may use either a 
  # single newline (0A), a single carriage return (0D), or a carriage return 
  # and newline combination (0D0A). For the purposes of successful data 
  # encoding and translation the elements <char code='0A'/> and 
  # <char code='0D'/> must be used to encode newline and carriage return 
  # characters when they should be preserved in the deserialized string.
  def test_serialize_special_characters
    xml = "<wddxPacket version='1.0'><header/><data><string><char code='0D'/></string></data></wddxPacket>"
    wddx = WDDX::Serializer::Serializer.new
    wddx.add_var "\r"
    assert_equal xml, wddx.to_xml
    
    xml = "<wddxPacket version='1.0'><header/><data><string><char code='0A'/></string></data></wddxPacket>"
    wddx = WDDX::Serializer::Serializer.new
    wddx.add_var "\n"
    assert_equal xml, wddx.to_xml
    
    xml = "<wddxPacket version='1.0'><header/><data><string><char code='0D'/><char code='0A'/></string></data></wddxPacket>"
    wddx = WDDX::Serializer::Serializer.new
    wddx.add_var "\r\n"
    assert_equal xml, wddx.to_xml        
  end
  
  # Calling add_var more than once will return an array element as the main container element for the serialized data.
  def test_serialize_consecutive_add_var_calls
    wddx = WDDX::Serializer::Serializer.new
    
    var1 = "A string"
    var2 = 1234
    var3 = WDDX::Binary.new("Bin data")

    wddx.add_var var1
    wddx.add_var var2
    wddx.add_var var3
    assert_equal(read_fixture("simple_array.2.xml"), wddx.to_xml)
  end
  
  def test_wddx_to_xml_result_cache
    wddx = WDDX::Serializer::Serializer.new
    wddx.add_var "A String"
    assert_equal("<wddxPacket version='1.0'><header/><data><string>A String</string></data></wddxPacket>", wddx.to_xml)
    
    wddx.add_var 123
    assert_equal("<wddxPacket version='1.0'><header/><data><array length='2'><string>A String</string><number>123</number></array></data></wddxPacket>", wddx.to_xml)
  end
  
  def test_to_s
    wddx = WDDX::Serializer::Serializer.new
    wddx.add_var "A String"
    assert_equal("<wddxPacket version='1.0'><header/><data><string>A String</string></data></wddxPacket>", wddx.to_s)
  end

  # Bugfix
  def test_serializer_to_wddx_properties
    xml = "<wddxPacket version='1.0'><header/><data><array length='3'><struct><var name='name'><string>test</string></var><var name='to_s'><string>1#test</string></var></struct><struct><var name='name'><string>test</string></var><var name='to_s'><string>2#test</string></var></struct><struct><var name='name'><string>test</string></var><var name='to_s'><string>3#test</string></var></struct></array></data></wddxPacket>"
    cls = (1..3).to_a.collect {|i| CustomClass.new(i, "test")}
    assert_equal xml, WDDX.dump(cls)
  end

end
