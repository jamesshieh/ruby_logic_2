A ruby symbolic logic parser.

Ruby Logic is built to parse symbolic logic statements following the format
below:

Propositions: A-Z
AND: &
OR: |
XOR : x
IMPIES: >
IFF: +
PARENS: ()
NOT: !
COMMAS: , separate statemets

Example:
A, !B, (A&B)>C, DxE+(A|B), ((A&E)|(C&D))>F

A single propositional statement is declared as a fact:
A     # A = true
!A    # A = false

The logic solver will attempt to resolve as many propositions as possible with
the given statements and facts:

Input:

A, B, (A&B)>C

Output:

Statement: A, B, (A&B)>C
Validity: true
Truth Table: {:A=>true, :B=>true, :C=>true}
Parsed Statements:
Type: declaration
A
Type: declaration
B
Type: statement
[implies [parens [and A B ] C ]
