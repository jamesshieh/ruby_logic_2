class Node
  attr_accessor :type, :left, :right

  def initialize(@type, @left, @right = nil)
    @left = left
    @right = right
    @type = type
  end
end

class Parser

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
      
      decl = parse_declaration(@tokens)

      if @tokens.empty?
        clauses << decl
        break
      elsif @tokens.peek == :comma
        clauses << decl
        tokens.shift # Remove comma
        next
      else
        @tokens = backup

        stmt = parse_statement(@tokens)

        if @tokens.empty?
          clauses << stmt
          break
        elsif @tokens.peek == :comma
          clauses << stmt
          tokens.shift # Remove comma
          next
        else 
          raise "Expecting comma, but got #{@tokens.peek}"
        end
      end
    end

    Node.new(:program, clauses)
  end

  # Declaration
  # declaration: negation

  def parse_declaration(tokens)
    parse_negation(tokens)
  end

  # Parse Statement
  # statement: iff

  def parse_statement(tokens)
    parse_iff(tokens)
  end

  # Parse Declaration negation
  # negation: ! negation
  #         | PROPOSITION

  def parse_negation(tokens)
    if !tokens.empty? && tokens.peek == :!
      tokens.shift
      parse_negation(tokens)
    else
      shift_and_expect(tokens, :proposition)
    end
  end

  # Parse parentheses
  # parens: ( iff )
  #       | PROPOSITION

  def parse_nesting(tokens)
    if !tokens.empty? && tokens.peek == :lparen
      # Process everything inside of parens
      tokens.shift # Shift starting "("

      expr = tokens.shift(tokens.scan_paren)
      left_tokens = Tokens.new(expr)
      left_parse_tree = parse_iff(left_tokens)
      
      tokens.shift # Shift matched ")"

      # Create new string with parentheses as one object
      expr = [left_parse_tree]
      while !tokens.empty?
        expr << tokens.shift
      end

      # Process new tokens string
      tokens = Tokens.new(expr)
      parse_tree = Node.new(:parens, parse_iff(tokens))
    elsif tokens.empty?
      return
    elsif tokens.peek == :proposition
      Node.new(:proposition, shift_and_expect(tokens, :proposition))
    end
  end

  # Parse out a unary not
  # not: ! not
  #    | parens

  def parse_not(tokens)
    if !tokens.empty? && tokens.peek == :!
      tokens.shift
      parse_tree = Node.new(:negation, parse_negation(tokens))
    else
      parse_tree = parse_nesting(tokens)
    end
  end

  # Parse out an and from two negations
  # and: negation { & negation }

  def parse_and(tokens)
    parse_tree = parse_negation(tokens)

    while !tokens.empty? && tokens.peek == :&
      tokens.shift
      parse_tree = Node.new(:and, parse_tree, parse_not(tokens))
    end

    parse_tree
  end

  # Parse out an or from two ands
  # or: and { | and }

  def parse_or(tokens)
    parse_tree = parse_and(tokens)

    while !tokens.empty? && tokens.peek == :|
      tokens.shift
      parse_tree = Node.new(:or, parse_tree, parse_and(tokens))
    end

    parse_tree
  end

  # Parse out an xor from two ors
  # xor: or { x or }

  def parse_xor(tokens)
    parse_tree = parse_or(tokens)

    while !tokens.empty? && tokens.peek == :x
      tokens.shift
      parse_tree = Node.new(:xor, parse_tree, parse_or(tokens))
    end

    parse_tree
  end

  # Parse implies
  # implies: xor { > xor }

  def parse_implies(tokens)
    parse_tree = parse_xor(tokens)

    while !tokens.empty? && tokens.peek == :>
      tokens.shift
      parse_tree = Node.new(:implies, parse_tree, parse_xor(tokens))
    end

    parse_tree
  end

  # Parse iff
  # iff: implies + implies

  def parse_iff(tokens)
    parse_tree = parse_implies(tokens)

    if !tokens.empty? && tokens.peek == :+
      tokens.shift
      parse_tree = Node.new(:iff, parse_tree, parse_implies(tokens))
    end

    parse_tree
  end

  # Shift and check type else raise exception

  def shift_and_expect(tokens, type)
    raise "Expecting a #{type}, instead reached end of input" if tokens.empty?
    raise "Expecting a #{type}, instead got #{tokens.peek}" if tokens.peek != type
    tokens.shift
  end
end
