require File.dirname(__FILE__) + '/test_helper.rb'

class TcWddxCoreextTest < Test::Unit::TestCase
   
  def test_true
    assert_equal("<boolean value='true'/>", true.wddx_serialize)
  end
  
  def test_false
    assert_equal("<boolean value='false'/>", false.wddx_serialize)
  end
  
  def test_symbol
    assert_equal "<string>a_symbol</string>", :a_symbol.wddx_serialize
    assert_equal "<string>Klaus Tester</string>", "Klaus Tester".intern.wddx_serialize
    assert_equal "abc".wddx_serialize, :abc.wddx_serialize
    assert :test.respond_to?(:to_wddx)
  end
  
  def test_string
    assert_equal("<string>Klaus Tester</string>", "Klaus Tester".wddx_serialize)
  end
  
  def test_array
    assert_equal("<array length='2'><number>10</number><string>second element</string></array>", [10, "second element"].wddx_serialize)
  end           
  
  def test_hash
    assert_equal("<struct><var name='key'><number>-12.456</number></var></struct>", {"key" => -12.456}.wddx_serialize)
  end          
    
  def test_hash_xml_escape_key
    assert_equal("<struct><var name='&amp;O&apos;Hara&lt;&gt;'><number>-12.456</number></var></struct>", {"&O'Hara<>" => -12.456}.wddx_serialize)
  end
  
  def test_int
    assert_equal("<number>123</number>", 123.wddx_serialize)
  end         
  
  def test_float
    assert_equal("<number>45.986</number>", 45.986.wddx_serialize)
  end
  
  def test_bignum
    assert_equal("<number>1.23456789123457e+17</number>", 123456789123456789.wddx_serialize)
  end
  
  def test_null
    assert_equal("<null/>", nil.wddx_serialize)
  end
  
  # Sat Jan 01 20:15:01 UTC 2000
  def test_time
    assert_equal("<dateTime>2000-01-01T20:15:01Z</dateTime>", Time.utc(2000,"jan",1,20,15,1).wddx_serialize)
  end
  
end