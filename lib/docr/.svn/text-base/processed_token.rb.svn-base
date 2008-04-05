module DocR
  class ProcessedToken
    attr_accessor :name, :parent
  
    def initialize(name, parent)
      @name = name
      @parent = parent
    end
  
    def ==(other)
      (self.name == other.name) && (self.parent == other.parent) 
    end
  end
end