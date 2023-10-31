# TODO LIST
- [ ] Better Error Handling / Messages
- [ ] More Compiler Features (compile whole directory)
- [ ] Unicode Character Support

## Compiler Components
- [x] Tokenizer
- [x] Sol Parser
    - [x] Parser Rewrite
- [x] Lua Transpiler
    - [ ] Transpiler Rewrite
    - [x] Indent Output Code
- [x] sol.lua Rewrite

# Preprocessor
- [ ] Define directive (#define \<name> \<value>)
- [x] Import directive (#import \<file>)

# Planned Features
- [x] String Interpolation ("Hello, my name is ${name} and I am ${age} years old")
- [x] Lua Table Support
- [ ] String Indexing: "Hello"[2] //-> 'e'
- [x] Default Parameters: fn example(arg = 5) { }

# Possible Features
- [ ] Const
- [ ] Enum
- [ ] Switch Statements
- [x] Ternary Operator (?:)
- [x] Operator Overloading