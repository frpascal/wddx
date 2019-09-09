# $Id: tc_wddx_complex_test.rb 94 2006-12-24 13:05:36Z stefan $

require File.dirname(__FILE__) + '/test_helper.rb'

class TcWddxComplexTest < Test::Unit::TestCase
  
  def test_dump_load_1
    # Time.now, 
    vals = [Math::PI, "A string", 123123, [[nil],[2],[1], [["A"], "B"], [[[6], [[6]]]]], {"a_key" => 3.2}].freeze
    w = []
    200.times do |i|
      w << vals[rand(7)]
    end
    
    actual = WDDX.load(WDDX.dump(w)).data
    w.each_with_index do |val,i|
      if val.kind_of?(Float)
        assert(val.to_s == actual[i].to_s)
      else
        assert_equal val, actual[i]
      end
    end
  end
  
end