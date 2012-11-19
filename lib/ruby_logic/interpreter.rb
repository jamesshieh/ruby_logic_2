class Interpreter

  def iniialize(parse_trees)
    @parse_trees = parse_trees
  end

  def solve(stmt)
    operator, left, right = stmt
    l, r = evaluate(left), evaluate(right)
    case operator.type
    when :&
      l && r
    when :|
      l || r
    when :x
      l ^ r
    when :>
      if l
        true
      else
        false
      end
    when :+
      l == r
    when :!
      ! l
    end
  end

  def evaluate(side)
    if side.class == array
      solve(array)
    elsif side.type == :proposition
      return side.truth
    end
  end

end
