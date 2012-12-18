Ruby Logic
==========

A symbolic logic parser written in ruby.

***

### To run

    bundle install
    bin/ruby_logic

### The language

Ruby logic is capable of parsing the following symbols in a symbolic logic
string:

    Propositions: A-Z
    AND: &
    OR: |
    XOR : x
    IMPIES: >
    IFF: +
    PARENS: ()
    NOT: !
    COMMAS: , (to separate statemets)

An example of a full statement:

    A, !B, (A&B)>C, DxE+(A|B), ((A&E)|(C&D))>F

A single propositional statement is declared as a fact:

    A     # A = true
    !A    # A = false

### Simple symbolic logic solving

The logic solver will attempt to resolve as many propositions as possible with
the given statements and facts:

Example:

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
