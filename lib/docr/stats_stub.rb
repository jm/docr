module DocR
  # Stubbed options object to feed to RDoc
  class RDocOptionsStub
    attr_accessor :files

    def initialize(file_list)
      @files = file_list
    end

    # Whatever else it wants doesn't matter.
    def method_missing(*args)
      false
    end
  end
end