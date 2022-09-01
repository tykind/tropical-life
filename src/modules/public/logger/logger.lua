--> @Desc Nice logging system
--> @Author Tykind
local Players = game:GetService("Players")

local logger = {}
logger.__index = logger

---> @Section Starting/Common functions
-------------

function logger.new(scriptName : string?)
    return setmetatable({
        Context = scriptName or "LOG"
    }, logger)
end

function logger:get_utc()
    local dt = DateTime.now()
    return dt:FormatUniversalTime("ddd MMM D YYYY | h:mm A", "en-us")
end

function logger:log(str)
    print(("[%s] [%s] - %s"):format(self:get_utc(), self.Context, str))
end

---> @Section Special functions
-------------


return logger