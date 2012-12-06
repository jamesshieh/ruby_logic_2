class Tokens < Array

  # Peek at first object and return it, return array object if array

  def peek
    self[0].class == Array ? :array : self[0].type
  end

  # Scan for the matching parentheses
  def scan_paren
    depth = 0
    self.each_with_index do |token, i|
      if token.type == :lparen
        depth += 1
      elsif token.type == :rparen && depth == 0
        return i
      elsif token.type == :rparen && depth > 0
        depth -= 1
      end
    end
    raise "Unable to find matched parentheses. Check to ensure you all parentheses are matching."
  end
end

# Token object

class Token
  attr_reader :type, :val

  def initialize(type, val = nil, truth = nil)
    @type = type
    @val = val
  end

end
