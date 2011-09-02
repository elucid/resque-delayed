class Fixnum
  def seconds
    to_i
  end
  alias :second :seconds

  def minutes
    seconds * 60
  end
  alias :minute :minutes

  def hours
    minutes * 60
  end
  alias :hour :hours

  def days
    hours * 24
  end
  alias :day :days
end
