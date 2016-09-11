# extend object functionality by in? method (reverse to Array::include? )
class Object
  def in?(collection)
    collection.respond_to?(:include?) ? collection.include?(self) : false
  end
end

class Integer
  def percent_of(num)
    self.to_f * 100 / num
  end
end

class Float
  def percent_of(num)
    self.to_f * 100 / num
  end
end
