class Interpreter

  def initialize(parse_trees, truth_table)
    @parse_trees, @truth_table = parse_trees, truth_table
    @solved = false
    @validity = true
  end

  # Loop solve until nothing more can be derived

  def solve_until_complete
    old_truth_table = nil
    while old_truth_table != @truth_table
      old_truth_table = @truth_table.dup
      solve_once
    end
    @solved = true
  end

  # One iteration of solving the statements

  def solve_once
    @parse_trees.each do |statement|
      if statement.class == Array && statement.length > 2
        case statement[0].type
        when :|
          test_or_implies(statement)
        when :>
          test_implies(statement)
        when :+
          test_iff(statement)
        end
      else
        set_given(statement)
      end
    end
  end

  # Is the statement provably true from the user's input

  def validity?
    solve_until_complete unless @solved
    @parse_trees.each do |statement|
      if statement.class == Array && statement.length > 2
        return false unless eval_stmt(statement)
      end
    end
    true
  end

  private

  # Set any givens

  def set_given(stmt)
    if stmt.class == Token
      val = stmt.val
      @truth_table[val] = true if @truth_table[val] == nil
      raise "Contradiction setting given: #{val}" unless @truth_table[val] == true
    else
      proposition = stmt[-1] if stmt[-1].type == :proposition
      val = proposition.val
      @truth_table[val] = false if @truth_table[val] == nil
      raise "Contradiction setting negated given: !#{val}" unless @truth_table[val] == false
    end
  end

  # Set a proposition

  def set_truth(val, truth)
    @truth_table[val] = truth if @truth_table[val] == nil
    raise "Contradiction setting truth value for: #{val}" unless @truth_table[val] == truth
  end

  # Return a statement broken into objects and truths

  def return_stmt_objects(stmt)
    operator, left = stmt[0], stmt[1]
    right ||= stmt[2] unless operator.type == :!
    l = eval_side(left)
    r ||= eval_side(right) unless operator.type == :!
    return operator, left, right, l, r
  end

  # Test for or implications

  def test_or_implies(stmt)
    operator, left, right, l, r = return_stmt_objects(stmt)
    raise "Expecting or instead got #{operator.type}" unless operator.type == :|
    if !l.nil? && !l
      set_truth(right.val, true)
    elsif !r.nil? && !r
      set_truth(left.val, true)
    end
  end

  # Test for valid implications

  def test_implies(stmt)
    operator, left, right, l, r = return_stmt_objects(stmt)
    raise "Expecting implies instead got #{operator.type}" unless operator.type == :>
    set_truth(right.val, true) if l
  end

  # Test for cases of IFF

  def test_iff(stmt)
    operator, left, right, l, r = return_stmt_objects(stmt)
    raise "Expecting iff instead got #{operator.type}" unless operator.type == :+
    if r && l.nil?
      set_truth(left.val, r)
    elsif l && r.nil?
      set_truth(right.val, l)
    end
  end

  # Evaluate a statement into a boolean

  def eval_stmt(stmt)
    operator, left, right, l, r = return_stmt_objects(stmt)
    return nil if l.nil? || r.nil? && operator.type != :!
    case operator.type
    when :!
      !l
    when :&
      l && r
    when :|
      l || r
    when :x
      l ^ r
    when :>
      if l
        r
      else
        false
      end
    when :+
      l == r
    end
  end

  # Evaluate a side into a boolean by recursively calling eval statement until
  # hitting a terminal proposition

  def eval_side(side)
    if side.class == Array
      eval_stmt(side)
    elsif side.type == :proposition
      return @truth_table[side.val]
    end
  end

end
