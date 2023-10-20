# Planned Features
- [x] String Interpolation ("Hello, my name is ${name} and I am ${age} years old")
- [ ] Lua Table Support
- [ ] String Indexing: "Hello"[2] //-> 'e'
- [ ] Default Parameters: fn example(arg = 5) { }

# Possible Features
- [ ] Const
- [ ] Enum
- [ ] Switch Statements
- [ ] Ternary Operator

# Possible Cursed? Features
- [ ] Arithmetic String Operations
    - Substring: 1-"Hello, World!"-8 //-> "ello"
    - Concatenation: "Hello,"+" World!" //-> "Hello, World!"
    - Repetition: "Hi"*4 //-> "HiHiHiHi"
    - Spliting:
        - "Hello, World!" / ',' //-> {"Hello", "World!"}
        - "Hello, World!" / 4 //-> {"Hell", "o, W", "orld"}
        - "Hello, World!" % 4 //-> '!'