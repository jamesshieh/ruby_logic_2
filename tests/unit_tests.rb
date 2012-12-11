$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__),".." , "lib")))
require 'ruby_logic'
require 'debugger'

def assert_equal(statement, expected)
  parser = Parser.new(statement)
  interpreter = Interpreter.new(parser.program, parser.truth_table)
  if interpreter.validity? != expected
    puts "Statement: #{statement}"
    puts "Expected #{expected} got #{interpreter.validity?}"
  end
end

test0 = "A, !B, A&B"
test1 = "A>C, A, !B, (A&!B)>D, A&(B|C)&D"


assert_equal("A", true)
assert_equal(test0, false)
assert_equal(test1, true)

