class Parser

  # TODO: create a data structure to store parsed product? operator/left/right
  # format

  def initialize(user_input)
    lexer = Lexer.new(user_input)
    @tokenized_input = lexer.tokenize_input
  end

  # Return a truth table

  def truth_table
    @truth_table ||= generate_truth_table(user_input)
  end

  # Return a parse tree

  def parse_trees
    @parse_trees ||= parse
  end

  private

  # Main parse function that is called

  def parse
    parse_trees = []
    @tokenized_input.each do |statement|
      parse_trees << parse_iff(statement)
    end
    parse_trees
  end

  # Generate a truth table

  def generate_truth_table(user_input)
    truth_table = {}
    propositions = user_input.scan(/[A-Z]/).uniq
    propositions.each do |prop|
      truth_table[prop.to_sym] = nil
    end
    truth_table
  end

  # Other parse levels

  # Parse nesting by segmenting out the statement in the parentheses then
  # calling normal parse function on it

  def parse_nesting(tokens)
    if !tokens.empty? && tokens.peek.type == :lparen
      tokens.shift
      matched_paren = tokens.scan_paren
      expr = tokens.shift(matched_paren)
      # TODO: clean up these statements which create Tokens objects out of
      # tokens
      left_tokens = Tokens.new
      expr.each do |token|
        left_tokens << token
      end
      left_parse_tree = parse_iff(left_tokens)
      tokens.shift
      # TODO: clean this up
      expr = [left_parse_tree]
      while !tokens.empty?
        expr << tokens.shift
      end
      # TODO: clean this up
      right_tokens = Tokens.new
      expr.each do |token|
        right_tokens << token
      end
      parse_tree = parse_iff(right_tokens)
    elsif tokens.empty?
      return
    elsif tokens.peek.type == :proposition || tokens.peek.type == :array
      tokens.shift
    end
  end

  # Parse out a unary negation
  # ! =>  ! ( expression )

  def parse_negation(tokens)
    parse_tree = parse_nesting(tokens)

    while !tokens.empty? && tokens.peek.type == :!
      parse_tree = [tokens.shift, shift_and_expect(tokens, :proposition)]
    end

    parse_tree
  end

  # Parse out an and from two negations
  # & => ! { & ! }

  def parse_and(tokens)
    parse_tree = parse_negation(tokens)

    while !tokens.empty? && tokens.peek.type == :&
      op = tokens.shift
      parse_tree = [op, parse_tree, parse_negation(tokens)]
    end

    parse_tree
  end

  # Parse out an or from two ands
  # | => & { | & }

  def parse_or(tokens)
    parse_tree = parse_and(tokens)

    while !tokens.empty? && tokens.peek.type == :|
      op = tokens.shift
      parse_tree = [op, parse_tree, parse_and(tokens)]
    end

    parse_tree
  end

  # Parse out an xor from two ors
  # x => | { x | }

  def parse_xor(tokens)
    parse_tree = parse_or(tokens)

    while !tokens.empty? && tokens.peek.type == :x
      op = tokens.shift
      parse_tree = [op, parse_tree, parse_or(tokens)]
    end

    parse_tree
  end

  # Parse implies
  # > => x > x

  def parse_implies(tokens)
    parse_tree = parse_xor(tokens)

    while !tokens.empty? && tokens.peek.type == :>
      op = tokens.shift
      parse_tree = [op, parse_tree, parse_xor(tokens)]
    end

    parse_tree
  end

  # Parse iff
  # + => > + >

  def parse_iff(tokens)
    parse_tree = parse_implies(tokens)

    while !tokens.empty? && tokens.peek.type == :+
      op = tokens.shift
      parse_tree = [op, parse_tree, parse_xor(tokens)]
    end

    parse_tree
  end

  # Shift and check type else raise exception

  def shift_and_expect(tokens, type)
    raise "Expecting a #{type}, instead reached end of input" if tokens.empty?
    raise "Expecting a #{type}, instead got #{tokens.peek.type}" if tokens.peek.type != type
    tokens.shift
  end
end
