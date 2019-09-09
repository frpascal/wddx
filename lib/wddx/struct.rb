#  $Id: struct.rb 110 2007-04-19 15:36:06Z stefan $
#  Created by Stefan Saasen.
#  Copyright (c) 2006. All rights reserved.

module WDDX   

  # Struct is a sorted Hash. Use with care and only 
  # if the sort order is important - use Hash instead! 
  class Struct < WddxData  # Besser von Hash ableiten
    include Enumerable
    
    def initialize
      @order = []
      @hash = {}
    end  
    
    # Calls *block* once for each key in WDDX::Struct, passing the key and value as parameter.
    def each
      @order.each do |key|
         yield(key, @hash[key]) 
      end if block_given? 
    end
    alias :each_pair :each
    
    def <=>(other)
      raise NotImplementedError
    end
    
    def grep(pattern)
      @order.map{|key| @hash[key]}.grep pattern
    end
    
    # Calls *block* for each key in WDDX::Struct, passing the key as the parameter.
    def each_key(&block)
      @order.each(&block)
    end
    
    # Calls *block* for each key in WDDX::Struct, passing the value as the parameter.  
    def each_value
      @order.each do |key|
        yield @hash[key]
      end if block_given?
    end       
    
    # Returns true if the given key is present in WDDX::Struct   
    def key?(arg)
      @order.include?(arg)
    end
    alias :has_key? :key?
    alias :member? :key?
    alias :include? :key?
    
    # Returns true if WDDX::Struct contains no key/value pairs 
    def empty?
      @order.empty?
    end
    
    # Element assignment - Associates the value given by *value* with the key given by *key*
    def put(key, value)
      @hash[key] = value
      @order << key unless @order.include?(key)
    end
    alias :add :put

    # Element assignment - Associates the value given by *value* with the key given by *key*
    def []=(key, value)
      put(key, value)
    end
    
    # Element reference - Retrieves the *value* stored for *key*.                   
    def [](key)
      @hash[key]
    end
    
    # Returns the number of key/value pairs in WDDX::Struct
    def size
      @order.size
    end                
    alias :length :size
    
    # Returns the element at _index_. A negative index counts from the
    # end of _self_. Returns +nil+ if the index is out of range.
    def at(position)
      @hash[@order.at(position)]
    end
    
    def inspect
      map { |k, v| [k, v] }.inspect
    end
    
    # Removes all key/value pairs from WDDX::Struct
    def clear
      @order.clear
      @hash.clear
    end
    
    # Removes the key and its associated value from the struct
    def delete(key)
      @order.delete(key)
      @hash.delete(key)
    end
    
    # Serialize WDDX::Struct
    def wddx_serialize # :nodoc:
      xml = ["<struct>"]
      self.each do |k,v|
        xml << "<var name='#{k}'>"
        if v.respond_to?(:wddx_serialize)
          xml << v.wddx_serialize  
        else
          xml << nil.wddx_serialize  
        end
        xml << "</var>"
      end
      xml << "</struct>"
      xml.join('')
    end
  end # end Struct
end