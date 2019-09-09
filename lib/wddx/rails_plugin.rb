#  $Id: rails_plugin.rb 109 2007-04-07 15:29:03Z stefan $
#  Created by Stefan Saasen.
#  Copyright (c) 2006. All rights reserved.

module RailsPlugin
  
  def to_wddx 
    a = attributes.dup
    a.to_wddx if a.respond_to?(:to_wddx)
  end
  
  def wddx_serialize
     attributes.wddx_serialize
  end

end

# Enhance AR::Base if present
ActiveRecord::Base.send(:include, RailsPlugin) if defined?(ActiveRecord)