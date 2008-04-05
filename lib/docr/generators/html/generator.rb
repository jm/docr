require 'erb'
require 'rdoc/rdoc'
require 'rdoc/markup'

module DocR
  class Generator
    def initialize(structure)
      # Setup our ERb objects
      @class_erb = ERB.new(File.open("#{File.dirname(__FILE__)}/default/class.erb").read, 0)
      @index_erb = ERB.new(File.open("#{File.dirname(__FILE__)}/default/index.erb").read, 0)
      
      @structure = structure
    end
    
    # Iterate the structure and generate HTML files
    #
    # TODO: Index file and refactor out writing file so user's get access to whole list of tokens
    def generate
      @structure.each do |klass_name, tokens|
        klass = tokens[0]
        methods = tokens[1]
        results = @class_erb.result(binding)
        
        File.open("#{Dir.getwd}/doc/#{klass.name}.html", 'w') do |f|
          f.write(results)
        end
      end
    end
  end
end