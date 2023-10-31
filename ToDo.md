# TODO LIST
- [ ] Better Error Handling / Messages

## Compiler Components
- [x] Tokenizer
- [x] Sol Parser
    - [x] Parser Rewrite
- [x] Lua Transpiler
    - [ ] Transpiler Rewrite
    - [x] Indent Output Code
- [x] sol.lua Rewrite

# Preprocessor
- [x] Define directive (#define \<name> \<value>)
- [x] Import directive (#import \<file>)

# Planned Features
- [ ] for loops
- [ ] elseif and else statements
- [x] String Interpolation ("Hello, my name is ${name} and I am ${age} years old")
- [x] Lua Table Support
- [x] Default Parameters: fn example(arg = 5) { }

# Possible Features
- [ ] Unicode Character Support
- [ ] Const
- [ ] Enum
- [ ] Switch Statements
- [ ] String Indexing: "Hello"[2] //-> 'e'
- [x] Ternary Operator (?:)
- [x] Operator Overloading