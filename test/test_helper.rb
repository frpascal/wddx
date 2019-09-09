# $Id: test_helper.rb 94 2006-12-24 13:05:36Z stefan $
require 'test/unit'
require File.dirname(__FILE__) + '/../lib/wddx'                                                   
FIXTURES = File.dirname(__FILE__) + "/fixtures"         

def is19?
  RUBY_VERSION >= "1.9.0"
end

def read_fixture(f)
  File.read(File.join(FIXTURES, f)).gsub(/\t|\n/, "").gsub(/^(.*)<wddx/, "<wddx").gsub(/"/, "'")
end
