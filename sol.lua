local args = dofile("./.sol/argser")(...)
  :num(1, 'input')
  :switch('output', 1):alias('o'):default({'*.lua'})
  :named('log')
  :parse().args

local Lexer = dofile('./.sol/tokenizer.lua')
local Parser = dofile('./.sol/parser.lua')
local Compiler = dofile('./.sol/transpiler.lua')

if not args.input then
    error('No Input (TODO: Better Errors)', 0)
end

file = args.input:match('(.*).sol$') or args.input
args.output[#args.output] = args.output[#args.output]:gsub('*', file)

function log(file, data)
    local log_path = './.sol/.logs'
    if not fs.exists(log_path) then
        fs.makeDir(log_path)
    end
    local h = fs.open(log_path .. '/' .. file, 'w')
    for k, v in pairs(data) do
        h.writeLine(textutils.serialize(v))
    end
    h.close()
end

local h = fs.open(args.input, 'r')
local data = h.readAll()
h.close()

local tokens = Lexer:lex(data)
if args.log then log('tokens.log', tokens) end

local ast = Parser:parse(tokens)
if args.log then log('ast.log', ast) end

local out = Compiler:compile(ast)
local h = fs.open(args.output[#args.output], 'w')
h.write(out)
h.close()