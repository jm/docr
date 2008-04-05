require 'rubygems'
# require 'ruport'

module DocR
  class TopLevel
    attr_accessor :comment
    
    def name
      "Top Level"
    end
    
    def full_name
      "Top Level"
    end
  end
  
  # RDoc's Stats class with our own stats thrown in and our own custom
  # print method.
  class Stats
    
    attr_accessor :num_files, :num_classes, :num_modules, :num_methods
    
    def initialize
      @num_files = @num_classes = @num_modules = @num_methods = 0
      @start = Time.now
    end
  
    # Print out the coverage rating
    def print
      puts
      puts
      
      puts "Files:   #{@num_files}"
      puts "Total Classes: #{@num_classes}"
      puts "Total Modules: #{@num_modules}"
      puts "Total Methods: #{@num_methods}"
      
      puts
    end
  end
end