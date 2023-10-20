--[[
        ===== Node Types =====
        ----------------------
        | Key:               |
        |  [*] - Finished    |
        |  [-] - In Progress |
        |  [ ] - Not Started |
        ----------------------
        [*] LocalDeclaration: value
        [*] VariableDeclaration: name, value
        [*] FunctionDeclaration: name, args, body
        [ ] ClassDeclaration: name, parent, body

        [*] FunctionCall: name, args
        [ ] MemberExpression: name, expr

        [-] IfStatement: expr, body
        [ ] ElseIfStatement: expr, body
        [ ] ElseStatement: body

        [*] WhileStatement: expr, body
        [ ] ForStatement: init, limit, step, body

        [*] ReturnStatement: value

        [*] BinaryExpression: op, left, right
        [-] UnaryExpression: op, value
        [*] ParenthesizedExpression: value

        [*] Literal: value

--]]
return {
    tokens = {},
    cursor = 1,
    precedence = {
        ['^'] = 7,
        ['unary'] = 6,
        ['%'] = 5,
        ['/'] = 5,
        ['*'] = 5,
        ['-'] = 4,
        ['+'] = 4,
        ['<='] = 3,
        ['>='] = 3,
        ['<'] = 3,
        ['>'] = 3,
        ['!='] = 2,
        ['=='] = 2,
        ['&&'] = 1,
        ['||'] = 1
    },
    getPrecedence = function(self, token)
        if (token == "unary") then
            return self.precedence.unary
        end

        if (token and self.precedence[token.value] ~= nil) then
            return self.precedence[token.value]
        end

        return 0
    end,

    peek =  function(self, offset)
        local offset = offset or 0
        return self.tokens[self.cursor+offset]
    end,
    match = function(self, tokenType, tokenValue, offset)
        local offset = offset or 0
        return (self:peek(offset).type == tokenType and (tokenValue == nil and true or tokenValue == self:peek(offset).value))
    end,
    consume = function(self)
        self.cursor = self.cursor + 1
        return self.tokens[self.cursor-1]
    end,
    try_consume = function(self, tokenType, tokenValue)
        if (self:peek().type == tokenType and (tokenValue == nil and true or tokenValue == self:peek().value)) then
            return self:consume()
        end
        error('Expected Token: ' .. tokenType .. (tokenValue ~= nil and (' [' ..tokenValue.. ']') or '')  .. ' got ' .. self:peek().value, 0)
    end,


    UnaryExpression = function(self)
        -- TODO: Unary Not
        self:try_consume(TokenTypes.OPERATOR, '-')
        return {
            ['type'] = "UnaryExpression",
            ['value'] = self:Expression(self:getPrecedence("unary")),
        }
    end,

    ParenthesizedExpression = function(self)
        self:try_consume(TokenTypes.SEPARATOR, '(')
        local expression = self:Expression()
        self:try_consume(TokenTypes.SEPARATOR, ')')
        return {
            ['type'] = 'ParenthesizedExpression',
            ['value'] = expression
        }
    end,

    Infix = function(self, left, operator)
        local token = self:try_consume(TokenTypes.OPERATOR, operator)
        local newPrec = self.precedence[token.value]

        return {
            ['type'] = "BinaryExpression",
            ['op'] = token.value,
            ['left'] = left,
            ['right'] = self:Expression(token.value == '^' and newPrec - 1 or newPrec),
        }
    end,

    Prefix = function(self)
        if (self:match(TokenTypes.SEPARATOR, '(')) then
            return self:ParenthesizedExpression()
        end

        if (self:match(TokenTypes.OPERATOR, '-')) then
            return self:UnaryExpression()
        end

        if (self:match(TokenTypes.KEYWORD, 'fn')) then
            self:consume()
            self:try_consume(TokenTypes.SEPARATOR, '(')
            local args = self:VarList()
            self:try_consume(TokenTypes.SEPARATOR, ')')
            self:try_consume(TokenTypes.SEPARATOR, '{')
            local body = self:StatementList()
            self:try_consume(TokenTypes.SEPARATOR, '}')
            return {
                ['type'] = 'AnonFunctionDeclaration',
                ['args'] = args,
                ['body'] = body
            }
        end

        if (self:match(TokenTypes.IDENTIFIER)) then
            if (self:match(TokenTypes.SEPARATOR, '(', 1)) then
                return self:FunctionCall()
            end

            local name = self:consume().value
            return {
                ['type'] = 'Literal',
                ['value'] = name
            }
        end

        if (self:match(TokenTypes.LITERAL)) then
            local token = self:consume()
            return {
                ['type'] = "Literal",
                ['value'] = token.value,
            }
        end
    end,

    Expression = function(self, prec)
        prec = prec or 0
        local left = self:Prefix()

        while (prec < self:getPrecedence(self:peek())) do
            left = self:Infix(left, self:peek().value)
        end

        return left
    end,

    VarList = function(self)
        local vars = {}
        if (not self:match(TokenTypes.IDENTIFIER)) then
            return nil
        end
        table.insert(vars, self:try_consume(TokenTypes.IDENTIFIER))
        while (self:match(TokenTypes.SEPARATOR, ',')) do
            self:consume()
            table.insert(vars, self:try_consume(TokenTypes.IDENTIFIER))
        end

        return vars
    end,

    ExprList = function(self)
        local exprs = {}
        if (self:match(TokenTypes.SEPARATOR, ')')) then
            return nil
        end
        table.insert(exprs, self:Expression())
        while (self:match(TokenTypes.SEPARATOR, ',')) do
            self:consume()
            table.insert(exprs, self:Expression())
        end

        return exprs
    end,

    VariableDeclaration = function(self)
        local ident = self:try_consume(TokenTypes.IDENTIFIER).value
        
        if (self:match(TokenTypes.OPERATOR, '=')) then
            self:consume()
        else
            -- TODO: This could probably be cleaner
            if (self:match(TokenTypes.OPERATOR, '+=')) then
                self:consume()
                table.insert(self.tokens, self.cursor, {
                    ['type'] = TokenTypes.OPERATOR,
                    ['value'] = '+'
                })
            elseif (self:match(TokenTypes.OPERATOR, '-=')) then
                self:consume()
                table.insert(self.tokens, self.cursor, {
                    ['type'] = TokenTypes.OPERATOR,
                    ['value'] = '-'
                })
            elseif (self:match(TokenTypes.OPERATOR, '*=')) then
                self:consume()
                table.insert(self.tokens, self.cursor, {
                    ['type'] = TokenTypes.OPERATOR,
                    ['value'] = '*'
                })
            elseif (self:match(TokenTypes.OPERATOR, '/=')) then
                self:consume()
                table.insert(self.tokens, self.cursor, {
                    ['type'] = TokenTypes.OPERATOR,
                    ['value'] = '/'
                })
            elseif (self:match(TokenTypes.OPERATOR, '%=')) then
                self:consume()
                table.insert(self.tokens, self.cursor, {
                    ['type'] = TokenTypes.OPERATOR,
                    ['value'] = '%'
                })
            else
                error('Invalid Assignment Operator', 0)
            end
            table.insert(self.tokens, self.cursor, {
                ['type'] = TokenTypes.IDENTIFIER,
                ['value'] = ident
            })
        end

        local expr = self:Expression()
        return {
            ['type'] = 'VariableDeclaration',
            ['name'] = ident,
            ['value'] = expr,
        }
    end,

    FunctionDeclaration = function(self)
        self:consume()
        local ident = self:try_consume(TokenTypes.IDENTIFIER).value
        self:try_consume(TokenTypes.SEPARATOR, '(')
        local args = self:VarList()
        self:try_consume(TokenTypes.SEPARATOR, ')')
        self:try_consume(TokenTypes.SEPARATOR, '{')
        local body = self:StatementList()
        self:try_consume(TokenTypes.SEPARATOR, '}')
        return {
            ['type'] = 'FunctionDeclaration',
            ['name'] = ident,
            ['args'] = args,
            ['body'] = body
        }
    end,

    FunctionCall = function(self)
        local ident = self:try_consume(TokenTypes.IDENTIFIER).value
        self:try_consume(TokenTypes.SEPARATOR, '(')
        local args = self:ExprList()
        self:try_consume(TokenTypes.SEPARATOR, ')')
        return {
            ['type'] = 'FunctionCall',
            ['name'] = ident,
            ['args'] = args
        }
    end,

    Statement = function(self)
        if (self:match(TokenTypes.KEYWORD, 'local')) then
            self:consume()
            if (self:match(TokenTypes.KEYWORD, 'fn')) then
                return {
                    ['type'] = 'LocalDeclaration',
                    ['value'] = self:FunctionDeclaration()
                }
            --[[ elseif (self:match(TokenTypes.KEYWORD, 'class')) then
                return {
                    ['type'] = 'LocalDeclaration',
                    ['value'] = self:ClassDeclaration()
                }
            ]]
            else
                return {
                    ['type'] = 'LocalDeclaration',
                    ['value'] = self:VariableDeclaration()
                }
            end
        -- elseif (self:match(TokenTypes.KEYWORD, 'class')) then
        elseif (self:match(TokenTypes.KEYWORD, 'fn')) then
            return self:FunctionDeclaration()
        elseif (self:match(TokenTypes.KEYWORD, 'if')) then
            self:consume()
            local expr = self:Expression()
            self:try_consume(TokenTypes.SEPARATOR, '{')
            local body = self:StatementList()
            self:try_consume(TokenTypes.SEPARATOR, '}')
            return {
                ['type'] = 'IfStatement',
                ['expr'] = expr,
                ['body'] = body,
            }
        elseif (self:match(TokenTypes.KEYWORD, 'while')) then
            self:consume()
            local expr = self:Expression()
            self:try_consume(TokenTypes.SEPARATOR, '{')
            local body = self:StatementList()
            self:try_consume(TokenTypes.SEPARATOR, '}')
            return {
                ['type'] = 'WhileStatement',
                ['expr'] = expr,
                ['body'] = body,
            }
        -- elseif (self:match(TokenTypes.KEYWORD, 'for')) then
            -- TODO: For Loop
        elseif (self:match(TokenTypes.KEYWORD, 'return')) then
            self:consume()
            return {
                ['type'] = 'ReturnStatement',
                ['value'] = self:Expression()
            }
        elseif (self:match(TokenTypes.IDENTIFIER) and self:match(TokenTypes.SEPARATOR, '(', 1)) then
            return self:FunctionCall()
        elseif (self:match(TokenTypes.IDENTIFIER)) then
            return self:VariableDeclaration()
        elseif (self:match(TokenTypes.SEPARATOR, '{')) then
            self:try_consume(TokenTypes.SEPARATOR, '{')
            local block = self:StatementList()
            self:try_consume(TokenTypes.SEPARATOR, '}')
            return {
                ['type'] = 'BlockStatement',
                ['value'] = block
            }
        else
            -- TODO: Class Declarations ( 'class' name (':' parent_name)? '{' body '}' )
            error('Unexpected Symbol ['..self:peek().line..']: ' .. self:peek().value, 0)
        end
    end,

    StatementList = function(self)
        local stmts = {}
        while (self:peek() ~= nil and self:peek().value ~= '}') do
            table.insert(stmts, self:Statement())
        end
        return stmts
    end,

    Program = function(self)
        return {
            ['type'] = 'Program',
            ['value'] = self:StatementList()
        }
    end,

    parse = function(self, tokens)
        self.tokens = tokens or {}
        return self:Program()
    end
}