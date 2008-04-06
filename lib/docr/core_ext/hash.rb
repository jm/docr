class Hash
  def meld(other)
    other = other.dup
    this = self.dup
    
    this.inject(other) do |hsh, (k,v)| 
      hsh[k] ||= []
      
      if hsh[k].is_a?(Hash) && v.is_a?(Hash)
        hsh[k] = hsh[k].meld(v)
      else
        unless hsh[k].is_a?(Array)
          hsh[k] = [hsh[k]]
        end
        
        hsh[k] << v
      end
      
      hsh
    end
  end
end