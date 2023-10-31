return {
    path = '',
    data = '',
    imports = function(self)
        for file in string.gmatch(self.data, '#import (%S*)') do
            file = file:sub(2, #file-1)
            local h = fs.open(self.path..file, 'r')
            local import = h.readAll()
            h.close()
            self.data = self.data:gsub(string.match(self.data, '#import %S*'), import)
        end
    end,

    defines = function(self)
        -- TODO: #define
    end,

    process = function(self, data, path)
        self.path = path
        self.data = data
        self:imports()
        -- self:defines()
        return self.data
    end,
}