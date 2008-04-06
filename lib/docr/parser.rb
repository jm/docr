require 'ruby_parser'
require 'pp'

module DocR
  class Parser
    def self.parse(code)
      setup_parser
      setup_structure
      
      tree = @parser.parse code
      walk tree
      
      pp @classes
      pp @modules
    end
    
    def self.walk(tree, parent_label=nil)
      tree.values.each do |token|
        case token[0]
        when :class
          @classes[token[1]] = add_class(token) 
        when :module
          @modules[token[1]] = add_module(token)
        end
      end
    end
    
    def self.add_class(token)
      {:comments => token.comments}.merge tokens_in(token.scope.block)
    end
    
    def self.add_module(token)
      {:comments => token.comments}.merge tokens_in(token.scope)
    end
    
    def self.add_method(token)
      {:comments => value.comments, :args => normalize_args(value.scope.block.args)}
    end
    
    def self.setup_parser
      @parser ||= RubyParser.new
    end
    
    def self.setup_structure
      @modules = {}
      @classes = {}
    end
    
    def self.tokens_in(parent)
      tokens = {:methods => {:class => {}, :instance => {}}, :classes => {}, :modules => {}}

      # Does it even have anything in it?
      if parent.respond_to?(:values)
        parent.values.each do |value|
          next unless value.is_a?(Sexp)
        
          if value[0] == :defn || value[0] == :defs
            # It's a method!
            if value[1] == s(:self)
              tokens[:methods][:class][value[2]] = value
            else
              tokens[:methods][:instance][value[1]] = add_method(value)
            end
          elsif value[0] == :class
            # d00d it's a class!
            tokens[:classes][value[1]] = add_class(value)
          elsif value[0] == :module
            # Module FTW!!!!
            tokens[:modules][value[1]] = add_module(value)
          else
            # Er, whut?
            puts "ARGGhHHH!!!!!!!!!!!!!!!!!"
            pp value
          end
        end
      end
      
      tokens
    end
    
    def self.normalize_args(args)
      
    end
  end
end