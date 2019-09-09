#  $Id: tc_wddx_rails_plugin_test.rb 94 2006-12-24 13:05:36Z stefan $
#  Created by Stefan Saasen.
#  Copyright (c) 2006. All rights reserved.

require 'rubygems'  
require 'active_record'

require File.dirname(__FILE__) + '/test_helper.rb'

class EmptyLogger
  def method_missing(sym, *args)
    # ignore
  end
end

# Mock up AR
ActiveRecord::Base.class_eval do
  alias_method :save, :valid?
  def self.columns() @columns ||= []; end
  
  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type, null)
  end
  
  def logger
    EmptyLogger.new
  end
  
end

# Mock class
class User < ActiveRecord::Base
  validates_presence_of :login
  column :id,       :integer
  column :login,    :string
  column :password, :string
  column :active,   :boolean, true
end


class TcWddxRailsPluginTest < Test::Unit::TestCase

  def setup
    @user = User.new :id => 10, :login => "stefan", :password => "geheim"
  end
  
  def test_true
    assert true
  end
  
  def no_test_plugin_setup
    assert defined?(ActiveRecord::Base)
    assert @user.respond_to?(:to_wddx), "AR should respond to :to_wddx"
    assert_equal({"password" => "geheim", "login" => "stefan", "active" => true}, WDDX.load(@user.to_wddx).data)
  end          

  def no_test_list
    xml = [@user.dup, @user.dup].to_wddx
    assert_equal({"password" => "geheim", "login" => "stefan", "active" => true}, WDDX.load(xml).data.first)
  end

end    
