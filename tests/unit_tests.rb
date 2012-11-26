$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__),".." , "lib")))
require 'ruby_logic'
require 'debugger'

test0 = "A"
parser = Parser.new(test0)
interpreter = Interpreter.new(parser.program, parser.truth_table)
puts test0
puts interpreter.truth_table
print "Expecting: true, Got: "
puts interpreter.validity?

test1 = "A>C, A, !B, (A&!B)>D, A&(B|C)&D"
parser = Parser.new(test1)
interpreter = Interpreter.new(parser.program, parser.truth_table)
puts test1
puts interpreter.truth_table
print "Expecting: true, Got: "
puts interpreter.validity?

test2 = "(A&B)>C, A, !B, B|D, D>C"
parser = Parser.new(test2)
interpreter = Interpreter.new(parser.program, parser.truth_table)
puts test2
puts interpreter.truth_table
print "Expecting: true, Got: "
puts interpreter.validity?

test3 = "A|C, !C, B, (A&B)"
parser = Parser.new(test3)
interpreter = Interpreter.new(parser.program, parser.truth_table)
puts test3
puts interpreter.truth_table
print "Expecting: true, Got: "
puts interpreter.validity?

test4 = "(A&B)&(C&D)|E, A, B, !C, !D, E"
parser = Parser.new(test4)
interpreter = Interpreter.new(parser.program, parser.truth_table)
puts test4
puts interpreter.truth_table
print "Expecting: true, Got: "
puts interpreter.validity?

