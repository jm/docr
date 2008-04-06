require 'ruby_parser'
require 'pp'
require 'core_ext/hash'

module DocR
  class Parser
    def self.parse(code)
      setup_parser
      setup_structure
      
      tree = @parser.parse code
      walk tree
      
      puts "found #{@classes.length} classes"
      
      pp @modules
      puts "found #{@modules[:ActiveRecord][:classes].length}"
      puts "found #{@modules.length} modules"
      
      puts "debug? "
      if gets() == "y"
        pp @classes
        pp @modules
      end
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
    
    def self.add_method(token, args)
      {:comments => token.comments, :args => normalize_args(args)}
    end
    
    def self.setup_parser
      @parser ||= RubyParser.new
    end
    
    def self.setup_structure
      @modules = {}
      @classes = {}
    end
    
    # TODO: Refactor to remove class_scoped param
    def self.tokens_in(parent, class_scoped=false)
      tokens = {:methods => {:class => {}, :instance => {}}, :classes => {}, :modules => {}, :includes => [], :constants => {}}

      # Does it even have anything in it?
      if parent.respond_to?(:values)
        parent.values.each do |value|
          @value = value
          next unless value.is_a?(Sexp)
        
          if value[0] == :defn || value[0] == :defs
            # It's a method!
            # TODO: Public/private/protected
            if value[1] == s(:self) || class_scoped == true
              # Class method
              # class << self blocks make this difficult...
              position = class_scoped ? 1 : 2
              tokens[:methods][:class][value[position]] = add_method(value, value.scope.args)
            else
              # Instance method
              tokens[:methods][:instance][value[1]] = add_method(value, value.scope.block.args)
            end
          elsif value[0] == :class
            # d00d it's a class!
            tokens[:classes][value[1]] = add_class(value)
          elsif value[0] == :module
            # Module FTW!!!!
            tokens[:modules][value[1]] = add_module(value)
          elsif value[0] == :cdecl
            # Constant declaration
            tokens[:constants][value[1]] = value[2]
          elsif value[0] == :sclass && value[1] == s(:self)
            # class << self block
            tokens = tokens.meld tokens_in(value.scope, true)
          elsif value[0] == :vcall
            # Switch protection level
          elsif value[0] == :fcall && value[1] == :include
            # Included module
            tokens[:includes] << value.array.const.value
          elsif value[0] == :cvdecl
            # Class variable declaration
          elsif value[0] == :fcall
            # Whutever
          elsif value[0] == :block
            tokens = tokens.meld tokens_in(value)
          else
            # Er, whut?
            puts "ARGGhHHH!!!!!!!!!!!!!!!!!"
            pp value
          end
        end
      end
      
      tokens
    rescue
      puts "!" * 200
      pp @value
    end
    
    def self.normalize_args(args)
      # If it's nil, then just return an empty Hash
      return {} unless args
      arguments = {}
      
      # Walk over the arguments and lasgn blocks
      # TODO: Figure out why there's lasagna in my code
      args.values.each do |arg|
        if arg.is_a?(Symbol)
          # New argument
          arguments[arg] = nil unless arguments.has_key?(arg)  # In case we already have a default value
        elsif arg.is_a?(Sexp)
          # Default value for an argument
          arguments[arg[1][1]] = arg[1][2].value
        end
      end
      
      arguments
    rescue
      {}
    end
  end
end