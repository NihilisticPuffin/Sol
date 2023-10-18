--[[
    === TODO LIST ===
    [ ] Better Error Handling / Messages
    [ ] More Compiler Features (compile whole directory)
    [ ] Ask Before File Override
    
    [*] Tokenizer
    [*] Sol Parser
        [-] Parser Rewrite
    [-] Lua Transpiler
        [ ] Transpiler Rewrite
        [*] Indent Output Code


    ===== Planned Features =====
    [*] String Interpolation ("Hello, my name is ${name} and I am ${age} years old")
    [ ] Lua Table Support
    [ ] String Indexing: "Hello"[2] //-> 'e'
    [ ] Default Parameters: fn example(arg = 5) { }

    ===== Possible Features =====
    [ ] Const
    [ ] Enum
    [ ] Switch Statements
    [ ] Ternary Operator

    ===== Possible Cursed? Features =====
    [ ] Arithmetic String Operations
        Substring: 1-"Hello, World!"-8 //-> "ello"
        Concatenation: "Hello,"+" World!" //-> "Hello, World!"
        Repetition: "Hi"*4 //-> "HiHiHiHi"
        Spliting:
                "Hello, World!" / ',' //-> {"Hello", "World!"}
                "Hello, World!" / 4 //-> {"Hell", "o, W", "orld"}
                "Hello, World!" % 4 //-> '!'
--]]
local args = {...}
options = {
    input = '',
    log = false,
}

for i = 1, #args do
    if (args[i] == '-i') then
        i = i+1
        if (args[i] == nil) then
            error('TODO: Compiler Error No Input', 0)
        end
        options.input = args[i]
    elseif (args[i] == '--log') then
        options.log = true
    end
end

if (options.input ~= '') then
    h = fs.open(options.input, 'r')
    data = h.readAll()
    h.close()
else
    error('No Input File', 0)
end

log_path = './.logs'
if options.log and not fs.exists(log_path) then
    fs.makeDir(log_path)
end

local Lexer = dofile('./tokenizer.lua')
local Parser = dofile('./parser.lua')
local Compiler = dofile('./transpiler.lua')

local tokens = Lexer:lex(data)
if options.log then
    h = fs.open(log_path .. '/tokens.log', 'w')
    for k, v in pairs(tokens) do
        h.writeLine(textutils.serialize(v))
    end
    h.close()
end

local ast = Parser:parse(tokens)
if options.log then
    h = fs.open(log_path .. '/ast.log', 'w')
    for k, v in pairs(ast) do
        h.writeLine(textutils.serialize(v))
    end
    h.close()
end

local out = Compiler:compile(ast)
file_path = options.input:gsub('.sol', '')
h = fs.open(file_path .. '.lua', 'w')
h.write(out)
h.close()