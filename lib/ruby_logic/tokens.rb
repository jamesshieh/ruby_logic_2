class Tokens < Array

  # Tokens class which is an array of tokens and can peek

  def initialize
    @array_token = Token.new(:array) # fake token to denote an array type
  end

  # Peek at first object and return it, return array object if array

  def peek
    if self[0].class == Array
      return @array_token
    end
    return self[0]
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
    raise "Unmatched paren"
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
