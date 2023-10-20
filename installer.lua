if fs.exists("./sol.lua") then shell.run("rm", "./sol.lua") end
if fs.exists("./.sol/") then shell.run("rm", "./.sol/") end

fs.makeDir("./.sol")

shell.run("wget", "https://raw.githubusercontent.com/NihilisticPuffin/Sol/main/sol.lua", "./sol.lua")
shell.run("wget", "https://raw.githubusercontent.com/NihilisticPuffin/Sol/main/.sol/tokenizer.lua", "./.sol/tokenizer.lua")
shell.run("wget", "https://raw.githubusercontent.com/NihilisticPuffin/Sol/main/.sol/parser.lua", "./.sol/parser.lua")
shell.run("wget", "https://raw.githubusercontent.com/NihilisticPuffin/Sol/main/.sol/transpiler.lua", "./.sol/transpiler.lua")
