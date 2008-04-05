class OptionsMock < Hash  
  def initialize
    self[:files] = "spec/mock_code.rb"
    self[:output_format] = "html"
    self[:path] = Dir.getwd
  end
  
  def method_missing(*args)
    false
  end
end