require 'rdoc/rdoc'

['processed_token', 'stats', 'core_ext/string', 'rdoc_patches', 'stats_stub'].each do |req|
  require File.dirname(__FILE__) + "/#{req}"
end

module DocR  
  # Main class
  class Parser    
    attr_accessor :hierarchy, :stats, :tokens, :structured_tokens
    
    # Grab the arguments from the DocR init script or
    # another calling script, feed them to RDoc for
    # parsing, then generate the documentation.
    # 
    # Right now, the guts of this method relies on a lot of 
    # the current RDoc, but I'm going to slowly replace
    # each piece of it with our own functionality.
    def initialize(options)
      @options = options
      raise "No files to document!" if @options[:files] == [] || @options[:files] == nil
      
      # Setup the analyzed tokens array so we can keep track of which methods we've already
      # taken a look at...
      @processed_tokens = []
      
      # Setup a hash for a properly structured, unabmbiguous token structure.
      # As nice as CodeObjects is, it references some things twice.
      @tokens = {:class => [], :module => [], :method => []}
      @structured_tokens = {}
      
      r = RDoc::RDoc.new
      
      # Instantiate our little patched Stats class...
      @stats = DocR::Stats.new
      r.stats = @stats
      
      # Setup any options we need here...
      Options.instance.parse(["--tab-width", 2], {})
            
      # We have to use #send because #parse_files is private
      #
      # TODO: 1.9 compatibility
      parsed_structure = r.send(:parse_files, RDocOptionsMock.new(options[:files]))
      
      # Analyze it, Spiderman!
      process parsed_structure
      
      # Generate the documentation!
      generate
    end
    
    def parse_files(options)
      file_list = normalized_file_list(options, files, true)

      file_info = []

      file_list.each do |fn|
        content = if RUBY_VERSION >= '1.9' then
                    File.open(fn, "r:ascii-8bit") { |f| f.read }
                  else
                    File.read fn
                  end

        if /coding:\s*(\S+)/ =~ content[/\A(?:.*\n){0,2}/]
          if enc = Encoding.find($1)
            content.force_encoding(enc)
          end
        end

        top_level = TopLevel.new(fn)
        parser = ParserFactory.parser_for(top_level, fn, content, options, @stats)
        file_info << parser.scan
        @stats.num_files += 1
      end

      file_info
    end
    
    # Method to initialize analysis of the code; passes
    # structure off to the process_token method which actually
    # processes each token.
    def process(hierarchy)
      @hierarchy = hierarchy

      # Iterate over all the tokens and process them accordingly
      @hierarchy.each do |hier| 
        hier.classes.each do |cls| 
          process_token cls
        end
        
        hier.modules.each do |mod|
          process_token mod
        end
      end
            
      # Create a properly nested structure for the tokens to live in
      @structured_tokens = {}
      tokens[:class].each do |cls| 
        @structured_tokens[cls.full_name] = [cls, {
                        :instance =>  {
                                        :public => [], 
                                        :private => [] 
                                      }, 
                        :class =>     {
                                        :public => [], 
                                        :private => []
                                      }
                        }]
      end
      
      tokens[:module].each do |mod| 
        @structured_tokens[mod.full_name] = [mod, {
                        :instance =>  {
                                        :public => [], 
                                        :private => []
                                      }, 
                        :class =>     {
                                        :public => [], 
                                        :private => []
                                      }
                        }]
      end
      
      @structured_tokens['[Toplevel]'] = [TopLevel.new, {
                        :instance =>  {
                                        :public => [], 
                                        :private => []
                                      }, 
                        :class =>     {
                                        :public => [], 
                                        :private => []
                                      }
                        }]
      
      # Structure method references
      tokens[:method].each do |method|
        if (@structured_tokens.has_key?(method.parent.full_name))
          @structured_tokens[method.parent.full_name][1][method.singleton ? :class : :instance][method.visibility.to_sym] << method
        else
          @structured_tokens['[Toplevel]'][1][method.singleton ? :class : :instance][method.visibility.to_sym] << method
        end
      end
      
      # Show us some code statistics!
      @stats.print   
    end
    
    # Method to process all the tokens for a token...recursion FTW! :)
    def process_token(token)
      # Create a ProcessedToken to make sure we don't process the same thing twice
      processed_token = ProcessedToken.new(token.name, token.parent)
      
      unless @processed_tokens.include?(processed_token)
        # Add to the right array of tokens
        tokens[token.classifier] << token
        @processed_tokens << processed_token
        
        # WTF!? :)
        raise token.method_list[0].singleton.inspect unless token.method_list[0].singleton rescue true
        
        # Process the tokens inside of this one accordingly
        [:method_list, :classes, :modules].each do |meth, type|
          token.send(meth).each do |item|
            process_token item
          end if token.respond_to?(meth)
        end
      end
    end
    
    # Generate the output based on the format specified.
    #
    # TODO: Have an argument sanity check at startup to make sure we actually have a generator for the format
    def generate
      print "Generating documentation..."
      
      # Require the generator
      require File.dirname(__FILE__) + "/generators/#{@options[:output_format]}/generator.rb"
      
      # Generate it!
      generator = DocR::Generator.new(structured_tokens)
      docs = generator.generate
      print "done.\n"
    end
    
    def param_names_for(token)
      # If there are parameters...
      if token.params
        # Duplicate
        params = token.params.dup
        # Remove parentheses
        params.gsub!(/\(/, '')
        params.gsub!(/\)/, '')

        # Multiple parameters?
        if params.include?(",")
          # ... split 'em up!
          params = params.split(",")
        else
          # ... or wrap in an array.
          params = [params]
        end

        processed_params = []

        params.each do |param|
          param_value = nil

          # We have a default value...
          if param.include?('=')
            param_pieces = param.scan(/(.*)=(.*)/)[0]
            param = param_pieces[0].strip 
            param_value = param_pieces[1].strip
          end

          # Add name and value
          processed_params << [param, param_value]
        end

        # No parameters or a fake list?
        if processed_params == [["", nil]]
          # Return an empty array...
          []
        else
          # Return the array of parameters
          processed_params  
        end
      else
        # No params?  Return an empty array
        []
      end
    end
  end
end   
