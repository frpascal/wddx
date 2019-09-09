#  $Id: record_set.rb 94 2006-12-24 13:05:36Z stefan $
#  Created by Stefan Saasen.
#  Copyright (c) 2006. All rights reserved.

module WDDX         

  class WddxData # :nodoc:
  end
  
  class Var < WddxData # :nodoc:
    attr_accessor :name, :value
    def initialize(name, value)
      @name, @value = name, value
    end     
    alias :key :name
  end  
  
  # == Recordsets
  # Recordsets are tabular data encapsulations: a set of named fields with 
  # the same number of rows of data. Only simple data types can be stored in
  # recordsets. For tabular data storage of complex data types, an array of 
  # structures should be used. Because some of the languages supported by WDDX
  # are not case-sensitive, no two field names can differ only by their case.
  # In the case where two fields have the same names or differ only by their
  # case the final deserialized values will be the values from the last field. 
  # Field names must satisfy the regular expression [_A-Za-z][_.0-9A-Za-z]* 
  # where the '.' stands for a period, not 'any character'.
  #  
  #  rows = []
  #  rows << [6, "MacBook Pro", 2000]
  #  rows << [10, "MacPro", 2200]
  #  rs = WDDX::RecordSet.new(["qty", "name", "price"], rows) 
  #  WDDX.dump(rs)
  # 
  # Or
  #
  #  rs = WDDX::RecordSet.new(["qty", "name", "price"])
  #  rs << [6, "MacBook Pro", 2000] 
  #  puts rs.size # => 1
  class RecordSet < WddxData   
    
    attr_reader :fields

    def initialize(field_names, fields = [])
      @field_names, @fields = field_names, fields
      @field_names.each do |f|
        raise ArgumentError unless f =~ /[_A-Za-z][_\.0-9A-Za-z]*/
      end
    end                                          
    
    # Return comma separated field names
    def field_names
      @field_names.join(',')
    end

    # Add an Array (one Row) with data fields
    def <<(row)
      # Don't accept invalid rows
      raise ArgumentError, "Invalid row for RecordSet" unless row.kind_of?(Array) and @field_names.size.eql?(row.size)
      @fields << row
    end
    
    # Returns the number of rows in the Recordset
    def row_count
      @fields.size
    end
    alias :size :row_count
    
    # Fetch 
    def fetch(field_name)
      fields.transpose[@field_names.index(field_name)]
    end
    alias :fetch_fields :fetch
    
    def wddx_serialize # :nodoc: 
      xml = ["<recordset rowCount='#{self.row_count}' fieldNames='#{self.field_names}'>"]
      self.columns do |name, fields|
        xml << "<field name='#{name}'>"
        xml << fields.collect {|f| f.wddx_serialize if f.respond_to?(:wddx_serialize) }
        xml << "</field>"
      end
      xml << "</recordset>"
      xml.join('')
    end
    
    def columns # :nodoc:
      raise ArgumentError, "No Block given!" unless block_given?
      col = 0
      @field_names.each do |field_name|
        fields = @fields.map{|row| row[col]}
        yield(field_name, fields)
        col += 1
      end
    end    
  end # RecordSet  
end