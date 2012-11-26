class Node
  attr_accessor :type, :left, :right

  def initialize(type, left, right = nil)
    @left = left
    @right = right
    @type = type
  end
end

module Parse

  # Declaration
  # declaration: negation

  def Parse.declaration(tokens)
    Node.new(:declaration, Parse.negation(tokens))
  end

  # Parse Statement
  # statement: iff

  def Parse.statement(tokens)
    Node.new(:statement, Parse.iff(tokens))
  end

  # Parse Declaration negation
  # negation: ! negation
  #         | PROPOSITION

  def Parse.negation(tokens)
    if !tokens.empty? && tokens.peek == :!
      tokens.shift
      Node.new(:negation, Parse.negation(tokens))
    else
      Node.new(:terminal, Parse.shift_and_expect(tokens, :proposition).val)
    end
  end

  # Parse parentheses
  # parens: ( iff )
  #       | PROPOSITION

  def Parse.nesting(tokens)
    if !tokens.empty? && tokens.peek == :lparen
      # Process everything inside of parens
      tokens.shift # Shift starting "("

      iff = Tokens.new(tokens.shift(tokens.scan_paren))

      tokens.shift # Shift matched ")"

      Node.new(:parens, Parse.iff(iff))
    elsif tokens.empty?
      return
    else
      Node.new(:terminal, Parse.shift_and_expect(tokens, :proposition).val)
    end
  end

  # Parse out a unary not
  # not: ! not
  #    | parens

  def Parse.not(tokens)
    if !tokens.empty? && tokens.peek == :!
      tokens.shift
      parse_tree = Node.new(:not, Parse.not(tokens))
    else
      parse_tree = Parse.nesting(tokens)
    end
  end

  # Parse out an and from two negations
  # and: negation { & negation }

  def Parse.and(tokens)
    parse_tree = Parse.not(tokens)

    while !tokens.empty? && tokens.peek == :&
      tokens.shift
      parse_tree = Node.new(:and, parse_tree, Parse.not(tokens))
    end

    parse_tree
  end

  # Parse out an or from two ands
  # or: and { | and }

  def Parse.or(tokens)
    parse_tree = Parse.and(tokens)

    while !tokens.empty? && tokens.peek == :|
      tokens.shift
      parse_tree = Node.new(:or, parse_tree, Parse.and(tokens))
    end

    parse_tree
  end

  # Parse out an xor from two ors
  # xor: or { x or }

  def Parse.xor(tokens)
    parse_tree = Parse.or(tokens)

    while !tokens.empty? && tokens.peek == :x
      tokens.shift
      parse_tree = Node.new(:xor, parse_tree, Parse.or(tokens))
    end

    parse_tree
  end

  # Parse implies
  # implies: xor { > xor }

  def Parse.implies(tokens)
    parse_tree = Parse.xor(tokens)

    while !tokens.empty? && tokens.peek == :>
      tokens.shift
      parse_tree = Node.new(:implies, parse_tree, Parse.xor(tokens))
    end

    parse_tree
  end

  # Parse iff
  # iff: implies + implies

  def Parse.iff(tokens)
    parse_tree = Parse.implies(tokens)

    if !tokens.empty? && tokens.peek == :+
      tokens.shift
      parse_tree = Node.new(:iff, parse_tree, Parse.implies(tokens))
    end

    parse_tree
  end

  # Shift and check type else raise exception

  def Parse.shift_and_expect(tokens, type)
    raise "Expecting a #{type}, instead reached end of input" if tokens.empty?
    raise "Expecting a #{type}, instead got #{tokens.peek}" if tokens.peek != type
    tokens.shift
  end
end

class Parser

  include Parse

  def initialize(user_input)
    @user_input = user_input
    lexer = Lexer.new(user_input)
    @tokens = lexer.tokens
  end

  # Return a truth table

  def truth_table
    @truth_table ||= generate_truth_table(@user_input)
  end

  # Return a parse tree

  def program
    @program ||= parse_program
  end

  private

  # Generate a truth table

  def generate_truth_table(user_input)
    truth_table = {}
    propositions = user_input.scan(/[A-Z]/).uniq
    propositions.each do |prop|
      truth_table[prop.to_sym] = nil
    end
    truth_table
  end

  # Main parse function that is called

  def parse_program
    clauses = []

    loop do
      backup = @tokens.dup

      begin
        decl = Parse.declaration(@tokens)

        if @tokens.empty?
          clauses << decl
          break
        elsif @tokens.peek == :comma
          clauses << decl
          @tokens.shift # Remove comma
          next
        else
          raise "Declaration failed, try statement"
        end
      rescue
        @tokens = backup

        stmt = Parse.statement(@tokens)

        if @tokens.empty?
          clauses << stmt
          break
        elsif @tokens.peek == :comma
          clauses << stmt
          @tokens.shift # Remove comma
          next
        else 
          raise "Expecting comma, but got #{@tokens.peek}"
        end
      end
    end

    Node.new(:program, clauses)
  end
end
