class Interpreter

  def iniialize(parse_trees)
    @parse_trees = parse_trees
  end

  def solve(stmt)
    operator, left= stmt
    right = stmt[2] unless operator.type == :!
    l = evaluate(left)
    right = evaluate(right) unless operator.type == :!
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
        true
      else
        false
      end
    when :+
      l == r
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
