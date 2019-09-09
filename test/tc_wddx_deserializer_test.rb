require File.dirname(__FILE__) + '/test_helper.rb'

class TcWddxDeserializerTest < Test::Unit::TestCase

  def setup
    @wddx = WDDX.load(File.open(FIXTURES + "/test.1.xml"))       
  end
                      
  def test_header
    assert @wddx.kind_of?(WDDX::WddxPacket)
    assert_equal 1.0, @wddx.version
    assert_equal "Das ist ein Kommentar", @wddx.comment
  end
  
  def test_data
    #assert_equal Hash, @wddx.data.class 
    assert @wddx.data.kind_of?(Hash)
    assert_equal 9, @wddx.data.size
  end

  def test_data_elements
    assert_not_nil @wddx.data
    keys = %w(aNull aString aNumber aDateTime aBoolean anArray aBinary anObject aRecordset)
    @wddx.data.each do |k,v| 
      keys.delete(k)
    end            
    assert_equal 0, keys.size
  end
                              
  def test_a_null
    assert_nil @wddx.data['aNull']
  end                
  
  def test_a_string
    assert_equal "a string", @wddx.data['aString']
  end                     
  
  def test_a_number
    assert_equal(-12.456, @wddx.data['aNumber'])
  end
  
  def test_a_datetime
    assert_equal "1998-06-11T16:32:12Z", @wddx.data['aDateTime'].gmtime.iso8601
  end                                                              
  
  def test_a_boolean
    assert @wddx.data['aBoolean']
  end   
  
  def test_an_object
    hash = {"n" => -12.456, "s" => "a string"}
    assert_equal hash, @wddx.data['anObject']
  end                
  
  def test_an_array
    ary = @wddx.data['anArray']  
    assert ary.kind_of?(Array)
    assert_equal 2, ary.size
    assert_equal 10, ary[0]
    assert_equal "second element", ary[1]
  end
  
  # WDDX DataType -> RecordSet
  def test_a_recordset
    recordset = @wddx.data["aRecordset"]
    assert recordset.kind_of?(WDDX::RecordSet)

    assert_equal ["John Doe", "Jane Doe"], recordset.fetch_fields("NAME")
    assert_equal [34, 31], recordset.fetch("AGE")    
  end                          
  
  # WDDX DataType -> Binary 
  def test_a_binary
     binary = @wddx.data["aBinary"]
     assert binary.kind_of?(WDDX::Binary)
     assert_equal "MIIBJASHETAS", binary.encode 
  end

  # File handling is different in Ruby 1.9 - use "rb:ascii-8bit" for 1.9
  def test_binary
    mode = is19? ? "rb:ascii-8bit" : "rb"
    bin_file_content = File.open("#{FIXTURES}/favicon.ico", mode).read
    c = WDDX.load(WDDX::Binary.new(bin_file_content).to_wddx)
    assert_equal bin_file_content, c.data.bin_data  
  end
 
  def no_test_ascii_characters
    # <wddxPacket version='1.0'><header/><data><string>A</string></data></wddxPacket>
    # int(65)
    # int(65)
    # bool(true)
    expect = []
    File.open(FIXTURES + "/ascii_characters.txt") do |f|
      wddx = nil
      f.each do |line|
        wddx = WDDX::Wddx.create(line) if line =~ /^<wddxPacket/
        if line =~ /int\(([0-9]+)\)/
          #assert_equal $1.to_i, (wddx.data.to_s)[0], "Character #{wddx.data.to_s}"
        end
      end
    end
  end

end
