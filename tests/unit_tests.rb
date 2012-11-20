$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__),".." , "lib")))
require 'ruby_logic'
require 'debugger'

test1 = "A>C, A, !B, (A&!B)>D, A&(B|C)&D"
parser = Parser.new(test1)
interpreter = Interpreter.new(parser.parse_trees, parser.truth_table)
print interpreter.validity?

test2 = "(A&B)>C, A, !B, B|D, D>C"
parser = Parser.new(test2)
interpreter = Interpreter.new(parser.parse_trees, parser.truth_table)
print interpreter.validity?

test3 = "A|C, !C, B, (A&B)"
parser = Parser.new(test3)
interpreter = Interpreter.new(parser.parse_trees, parser.truth_table)
print interpreter.validity?

test4 = "(A&B)&(C&D)|E, A, B, !C, !D, E"
parser = Parser.new(test4)
interpreter = Interpreter.new(parser.parse_trees, parser.truth_table)
print interpreter.validity?

