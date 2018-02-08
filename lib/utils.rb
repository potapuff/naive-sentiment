class Array
  def rand
    self.empty? ? nil : self[Kernel.rand(self.size)]
  end
end