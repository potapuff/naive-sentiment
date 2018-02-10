class Array
  def rand
    self.empty? ? nil : self[Kernel.rand(self.size)]
  end
end

class Pair
  attr_accessor :count, :sum
  def initialize( count = 0, sum = 0)
    @count = count
    @sum   = sum
  end

  def increment!(factor=1)
    @count += 1
    @sum += factor
  end

  def factor
    @count > 0 ? @sum.to_f/@count.to_f : 0
  end

  def to_s
    "%2.1f" % factor
  end
end