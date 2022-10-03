--> @Desc Nice logging system
--> @Author Tykind
local Players = game:GetService("Players")
local TestService = game:GetService("TestService")

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

function logger:log(str, ...)
    TestService:Message(("[%s] [%s] - %s"):format(self:get_utc(), self.Context, str:format(...)))
end

function logger:err(str, ...)
    TestService:Error(("[%s] [%s] - %s"):format(self:get_utc(), self.Context, str:format(...)))
end

---> @Section Special functions
-------------


return logger