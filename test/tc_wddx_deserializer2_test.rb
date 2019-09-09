require File.dirname(__FILE__) + '/test_helper.rb'

class TcWddxDeserializer2Test < Test::Unit::TestCase

  def setup
    @wddx = WDDX.load(File.open(FIXTURES + "/java.test.xml"))       
  end
  
  def test_data_global
    assert @wddx.data.kind_of?(Array)
    assert_equal 11, @wddx.data.size
  end
  
  
  def test_string_elements
    d = @wddx.data
    assert_equal "This is array element #1", d[0]
    assert_equal "This is array element #2", d[1]
    assert_equal "This is array element #3", d[2]
    assert_equal "Some special characters, e.g., control characters\a\v				,pre-defined entities <&>, and high-ASCII values \302\200\303\277.", d[3]
    assert_equal "true", d[5]
  end                       
  
  def test_struct_elements
    d = @wddx.data
    struct = {"B" => "b", "A" => "a"}
    assert_equal struct, d[4]
  end                       
  
  def test_number
    d = @wddx.data
    assert_equal(-12.456, d[6])
  end
                           
  def test_array
    ary = @wddx.data[9]
    assert_equal("1", ary[0])
    assert_equal("2", ary[1])
    assert_equal("3", ary[2])
  end
  
  def test_array_of_arrays
    ary = @wddx.data[10]
    assert_equal(3, ary.size)
    assert_equal(1, ary[0].size)
    assert_equal(2, ary[1].size)
    assert_equal(3, ary[2].size)
    assert_equal("1", ary[0][0])    
    assert_equal("2", ary[1][1])
    assert_equal("3", ary[2][2])
  end
  
end