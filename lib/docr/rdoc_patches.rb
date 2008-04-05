# Makes +stats+ accessible to us so we can inject our own.
# We also add a +classifier+ attribute to the code object classes.
module RDoc
  class RDoc
    attr_accessor :stats
  end
  
  module Helpers
    def initialize(*args)
      super(*args)
    end
    
    def full_name
      hierarchy = self.name
      inspect = self
      while (hier_piece = inspect.parent)
        hierarchy = hier_piece.name + "::" + hierarchy unless hier_piece.name == 'TopLevel'
        inspect = hier_piece
      end
      
      hierarchy
    end
  end
  
  class AnyMethod
    include Helpers
    
    def classifier
      :method
    end
  end
  
  class NormalClass
    include Helpers
    
    def classifier
      :class
    end
  end
  
  class NormalModule
    include Helpers
    
    def classifier
      :module
    end
  end
end