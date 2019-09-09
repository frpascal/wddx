# $Id: wddx_test.rb 109 2007-04-07 15:29:03Z stefan $
require File.dirname(__FILE__) + '/test_helper.rb'
require 'test/unit'

if defined?(ActiveRecord)
  # Include all TestCases
  Dir[File.dirname(__FILE__) + "/tc_*"].each {|tc| require tc}
else
  # Skip Rails Tc
  Dir[File.dirname(__FILE__) + "/tc_*"].reject{|tc| tc =~ /rails/i }.each {|tc| require tc}
end