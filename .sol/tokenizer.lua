TokenTypes = {
    ['IDENTIFIER'] = 'IDENTIFIER',
    ['KEYWORD'] = 'KEYWORD',
    ['SEPARATOR'] = 'SEPARATOR',
    ['OPERATOR'] = 'OPERATOR',
    ['LITERAL'] = 'LITERAL',
}

local KEYWORDS = {
    ['if'] = true,
    ['else'] = true,
    ['while'] = true,
    ['for'] = true,
    ['fn'] = true,
    ['class'] = true,
    ['local'] = true,
    ['return'] = true,
}

return {
    cursor = 1,
    start = 1,
    source = '',
    line = 1,
    tokens = {},
    atEnd = function(self) return self.cursor > #self.source end,
    read = function(self, offset) offset= offset or 0 return self.source:sub(self.cursor+offset, self.cursor+offset) end,
    addToken = function(self, t, v)
        table.insert(self.tokens, {
            ['type'] = t,
            ['value'] = v,
            ['line'] = self.line
        })
    end,

    lex = function(self, input)
        self.source = input
        while not self:atEnd() do
            self.start = self.cursor
            local char = self:read()

            if char == ';' or char == '(' or char == ')' or char == '{' or char == '}' or char == '[' or char == ']' or char == ',' or char == '.' then
                self.cursor = self.cursor+1
                self:addToken(TokenTypes.SEPARATOR, char)
            elseif char == '+' or char == '-' or char == '*' or char == '/' or char == '%' or char == '^' or char == '<' or char == '>' or char == '=' or char == '!' or char == '#' then
                self.cursor = self.cursor+1
                if self:read() == '=' then
                    self.cursor = self.cursor+1
                end
                if (char == '/' and self:read() == '/') or (char == '#' and self:read() == '!') then
                    while self:read() ~= '\n' do self.cursor = self.cursor+1 end
                elseif (char == '/' and self:read() == '*') then
                    repeat self.cursor = self.cursor+1 until self:read(-2) == '*' and self:read(-1) == '/'
                else
                    self:addToken(TokenTypes.OPERATOR, self.source:sub(self.start, self.cursor-1))
                end
            elseif char == '&' or char == '|' then
                self.cursor = self.cursor+1
                if self:read() == char then
                    self.cursor = self.cursor+1
                end
                self:addToken(TokenTypes.OPERATOR, self.source:sub(self.start, self.cursor-1))
            elseif char == '?' or char == ':' then
                self.cursor = self.cursor+1
                self:addToken(TokenTypes.OPERATOR, self.source:sub(self.start, self.cursor-1))
            elseif char == '"' or char == "'" then
                self.cursor = self.cursor+1
                while self:read() ~= char do self.cursor = self.cursor + 1 end
                self:addToken(TokenTypes.LITERAL, self.source:sub(self.start, self.cursor))
                self.cursor = self.cursor+1
            elseif char:match('[%a_.]') then
                self.cursor = self.cursor+1
                while self:read():match('[%w_.]') do self.cursor = self.cursor + 1 end
                local ident = self.source:sub(self.start, self.cursor-1)
                if ident == 'true' or ident == 'false' then
                    self:addToken(TokenTypes.LITERAL, ident)
                elseif KEYWORDS[ident] then
                    self:addToken(TokenTypes.KEYWORD, ident)
                else
                    self:addToken(TokenTypes.IDENTIFIER, ident)
                end
            elseif char:match('%d') then
                self.cursor = self.cursor+1
                while self:read():match('%d') do self.cursor = self.cursor + 1 end
                if self:read() == '.' then self.cursor = self.cursor+1 while self:read():match('%d') do self.cursor = self.cursor + 1 end end
                self:addToken(TokenTypes.LITERAL, self.source:sub(self.start, self.cursor-1))
            elseif char == '\n' then
                self.line = self.line + 1
                self.cursor = self.cursor+1
            elseif char:match('%s') then
                self.cursor = self.cursor+1
            else
                error('['.. self.line ..'] Unexpected Token: ' .. char, 0)
            end
        end

        return self.tokens
    end
}