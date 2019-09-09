# $Id: tc_wddx_recordset_test.rb 94 2006-12-24 13:05:36Z stefan $
require File.dirname(__FILE__) + '/test_helper.rb'

class TcWddxRecordsetTest < Test::Unit::TestCase
  def test_recordset_setup
    rs = WDDX::RecordSet.new(["Name", "email", "date_of_birth"])
    rs << ["Klaus Tester", "klaus@example.com", Time.at(1000000)]
    rs << ["Stefan", "s@example.com", Time.at(899999)]

    assert_equal 2, rs.size
    assert_equal 2, rs.row_count
    
    # Don't accept invalid rows
    assert_raises ArgumentError do 
      rs << [] # invalid row
    end
    
    assert_equal ["Klaus Tester", "Stefan"], rs.fetch("Name")
  end
  
  
  def test_recordset_setup_2
    rows = []
    rows << [6, "MacBook Pro", 2000]
    rows << [10, "MacPro", 2200]
    rs = WDDX::RecordSet.new(["qty", "name", "price"], rows)
    
    assert_equal 2, rs.size
    assert_equal ["MacBook Pro", "MacPro"], rs.fetch("name") 
  end
end