# $Id: tc_wddx_struct_test.rb 110 2007-04-19 15:36:06Z stefan $
require File.dirname(__FILE__) + '/test_helper.rb'

class TcWddxStructTest < Test::Unit::TestCase
  
  def test_struct_setup
    s = WDDX::Struct.new
    
    s["k"] = "s"
    s[:k] = "w"
    
    assert_equal 2, s.size
    assert_equal 2, s.length
    
    assert_equal "s", s["k"]
    assert_equal "w", s[:k]
    
    s.each_key do |k|
      assert ["k", :k].include?(k)
    end
    assert_key_order s, "k", :k
    
    s.each_value do |k|
      assert ["s", "w"].include?(k)
    end
    assert_value_order s, "s", "w"
                     
    assert_equal "w", s.at(1)
    assert_equal "s", s.at(0)
    assert_nil s.at(19)
    
    
    s.put 123, Math::PI
    
    assert_equal 3, s.size
  end 
  
  def test_enumerable
     s = WDDX::Struct.new
     s[1] = "eins"
     s[2] = "zwei"
     s[3] = "drei"
     assert s.respond_to?(:each_with_index)
     assert s.respond_to?(:include?)

     s.each_with_index do |elem, i|          
       assert elem.kind_of?(Array)
       assert i < 3
     end
                   
     assert s.include?(1)
     assert !s.include?(5)
                         
     assert_equal ["drei"], s.grep(/re/)
     
  end
  
  def test_get_non_existent
    s = WDDX::Struct.new
    assert_nil s['does not exist']
  end
  
  def test_no_duplicate_keys
    s = WDDX::Struct.new
    s['foo'] = 'bar'
    s['foo'] = 'quux'
    
    assert_equal "<struct><var name='foo'><string>quux</string></var></struct>",
                 s.wddx_serialize
  end
  
  def test_order_retained
    s = WDDX::Struct.new
    s['foo'] = 8
    s['bar'] = 12
    s['quux'] = 3
    
    assert_key_order s, 'foo', 'bar', 'quux'
    assert_value_order s, 8, 12, 3
  end
  
  def test_order_retained_when_value_reset
    s = WDDX::Struct.new
    s['foo'] = 8
    s['bar'] = 12
    s['quux'] = 3
    s['bar'] = 5
    s['foo'] = 17
    
    assert_key_order s, 'foo', 'bar', 'quux'
    assert_value_order s, 17, 5, 3
  end
  
  def test_delete
    s = WDDX::Struct.new
    s['foo'] = 8
    s['bar'] = 12
    s['quux'] = 3
    
    s.delete('bar')
    
    assert_key_order s, 'foo', 'quux'
    assert_value_order s, 8, 3
  end
  
  private
  
  def assert_key_order(struct, *keys)
    assert_equal keys.size, struct.size
    order = struct.map { |k, v| k }
    (0 .. (keys.size)).each do |i|
      assert_equal keys[i], order[i], "mismatch at key #{i}"
    end
  end
  
  def assert_value_order(struct, *vals)
    assert_equal vals.size, struct.size
    order = struct.map { |k, v| v }
    (0 .. (vals.size)).each do |i|
      assert_equal vals[i], order[i], "mismatch at value #{i}"
    end
  end
end