class Interpreter

  def initialize(program, truth_table)
    @program, @truth_table = program, truth_table
    @solved = false
    @validity = true
  end

  def truth_table
    solve_until_complete unless @solved
    @truth_table
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
    @program.left.each do |clause|
      case clause.type
      when :declaration
        set_given(clause.left)
      when :statement
        case clause.left.type
        when :or
          test_or_implies(clause.left)
        when :implies
          test_implies(clause.left)
        when :iff
          test_iff(clause.left)
        end
      end
    end
  end

  # Is the statement provably true from the user's input

  def validity?
    solve_until_complete unless @solved
    @program.left.each do |clause|
      if clause.type == :statement
        return false unless eval_stmt(clause.left)
      end
    end
    true
  end

  private

  # Set any givens

  def set_given(stmt, truth = true)
    if stmt.type == :terminal
      val = stmt.left
      if @truth_table[val].nil?
        @truth_table[val] = truth
      else
        raise "Contradiction setting given: #{val}" unless @truth_table[val] == truth
      end
    else
      if stmt.type == :negation
        set_given(stmt.left, !truth)
      end
    end
  end

  # Set a proposition

  def set_truth(val, truth = true)
    @truth_table[val] = truth if @truth_table[val] == nil
    raise "Contradiction setting truth value for: #{val}" unless @truth_table[val] == truth
  end

  # Test for or implications

  def test_or_implies(stmt)
    l = eval_side(stmt.left)
    r = eval_side(stmt.right)
    if !l.nil? && !l
      set_truth(stmt.right.left) if stmt.right.type == :terminal
    elsif !r.nil? && !r
      set_truth(stmt.left.left) if stmt.left.type == :terminal
    end
  end

  # Test for valid implications

  def test_implies(stmt)
    l = eval_side(stmt.left)
    set_truth(stmt.right.left) if l && stmt.right.type == :terminal
  end

  # Test for cases of IFF

  def test_iff(stmt)
    l = eval_side(stmt.left)
    r = eval_side(stmt.right)
    if r && l.nil?
      set_truth(stmt.left.left, r) if stmt.left.type == :terminal
    elsif l && r.nil?
      set_truth(stmt.right.left, l) if stmt.right.type == :terminal
    end
  end

  # Evaluate a statement into a boolean

  def eval_stmt(stmt)
    l = eval_side(stmt.left)
    r = eval_side(stmt.right)
    case stmt.type
    when :not
      !l
    when :and
      l && r
    when :or
      l || r
    when :xor
      l ^ r
    when :implies
      if l
        r
      else
        r
      end
    when :iff
      l == r
    when :parens
      l
    end
  end

  # Evaluate a side into a boolean by recursively calling eval statement until
  # hitting a terminal proposition

  def eval_side(side)
    return nil if side.nil?
    if side.type == :terminal
      return @truth_table[side.left]
    else
      eval_stmt(side)
    end
  end

end
