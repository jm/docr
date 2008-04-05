class String
  # Lets us clean up comment strings
  def clean
    gsub(/\n#/, '').gsub(/^#/, '')
  end
end