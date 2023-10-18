return {
    ast = {},
    output = '',
    depth = 0,

    indent = function(self)
        local tabs = ''
        for i=0, self.depth-1 do
            tabs = tabs .. '    '
        end
        return tabs
    end,

    visitLiteral = function(self, node)
        if node.value:sub(1, 1) == '"' or node.value:sub(1, 1) == "'" then
            if node.value:match('${%w*}') then
                local tmp = node.value:gsub('${(%w*)}', "%%s")
                local out = 'string.format(' .. tmp .. ', '
                for w in node.value:gmatch("${(%w*)}") do
                    out = out .. w .. ', '
                end
                return out:sub(1, #out-2) .. ')'
            end
        end
        return node.value
    end,

    visitVariableDeclaration = function(self, node)
        return node.name .. ' = ' .. self:visit(node.value)
    end,

    visitParenthesizedExpression = function(self, node)
        return '(' .. self:visit(node.value) .. ')'
    end,
    visitUnaryExpression = function(self, node)
        return '-' .. self:visit(node.value)
    end,

    visitBinaryExpression = function(self, node)
        if node.op == '!=' then node.op = '~=' end
        if node.op == '&&' then node.op = 'and' end
        if node.op == '||' then node.op = 'or' end
        return self:visit(node.left) .. ' ' .. node.op .. ' ' .. self:visit(node.right)
    end,

    visitFunctionCall = function(self, fn)
        local fn_args = ''
        if (fn.args) then
            for k, node in ipairs(fn.args) do
                fn_args = fn_args .. ((k > 1) and ', ' or '') .. self:visit(node)
            end
        end
        return fn.name .. '('.. fn_args ..')'
    end,
    visitFunctionDeclaration = function(self, fn)
        local fn_out = ''
        self.depth = self.depth + 1
        for _, node in ipairs(fn.body) do
            fn_out = fn_out .. self:indent() .. self:visit(node) .. '\n'
        end
        self.depth = self.depth - 1
        local fn_args = ''
        if (fn.args) then
            for k, node in ipairs(fn.args) do
                fn_args = fn_args .. ((k > 1) and ', ' or '') .. node.value
            end
        end
        return 'function ' .. fn.name .. '('.. fn_args ..')\n' .. fn_out  .. self:indent() .. 'end'
    end,
    visitAnonFunctionDeclaration = function(self, fn)
        local fn_out = ''
        for _, node in ipairs(fn.body) do
            fn_out = fn_out .. self:visit(node) .. '\n'
        end
        local fn_args = ''
        if (fn.args) then
            for k, node in ipairs(fn.args) do
                fn_args = fn_args .. ((k > 1) and ', ' or '') .. node.value
            end
        end
        return 'function ' .. '('.. fn_args ..')\n' .. fn_out .. 'end'
    end,

    visitIfStatement = function(self, node)
        return 'if ' .. self:visit(node.expr) .. ' ' .. self:visitBlock(node.body, true)
    end,
    visitWhileStatement = function(self, node)
        return 'while ' .. self:visit(node.expr) .. ' ' .. self:visitBlock(node.body)
    end,

    visitReturn = function(self, node)
        return 'return ' .. self:visit(node.value)
    end,

    visitBlock = function(self, block, useThen)
        self.depth = self.depth + 1
        local block_out = (useThen and 'then' or 'do') ..'\n'
        for _, node in ipairs(block) do
            block_out = block_out .. self:indent() .. self:visit(node).. '\n'
        end
        self.depth = self.depth - 1
        return block_out .. self:indent() .. 'end\n'
    end,

    visitProgram = function(self, ast)
        for _, node in ipairs(ast.value) do
            self.output = self.output .. self:visit(node) .. '\n'
        end
        return self.output:sub(1, #self.output-1) -- Remove Trailing new line
    end,

    visit = function(self, node)
        if node.type == 'Program' then
            return self:visitProgram(node)
        elseif node.type == 'BlockStatement' then
            return self:visitBlock(node.value)
        elseif node.type == 'ReturnStatement' then
            return self:visitReturn(node)
        elseif node.type == 'IfStatement' then
            return self:visitIfStatement(node)
        elseif node.type == 'WhileStatement' then
            return self:visitWhileStatement(node)
        elseif node.type == 'LocalDeclaration' then
            return 'local ' .. self:visit(node.value)
        elseif node.type == 'VariableDeclaration' then
            return self:visitVariableDeclaration(node)
        elseif node.type == 'FunctionDeclaration' then
            return self:visitFunctionDeclaration(node)
        elseif node.type == 'AnonFunctionDeclaration' then
            return self:visitAnonFunctionDeclaration(node)
        elseif node.type == 'FunctionCall' then
            return self:visitFunctionCall(node)
        elseif node.type == 'Literal' then
            return self:visitLiteral(node)
        elseif node.type == 'BinaryExpression' then
            return self:visitBinaryExpression(node)
        elseif node.type == 'UnaryExpression' then
            return self:visitUnaryExpression(node)
        elseif node.type == 'ParenthesizedExpression' then
            return self:visitParenthesizedExpression(node)
        else
            return '==Invalid Node=='
        end
    end,

    compile = function(self, ast)
        self.ast = ast
        return self:visit(self.ast)
    end,
}