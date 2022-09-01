--> @Desc Quick data accesser
--> @Author Tykind

local ReplicatedStorage = game:GetService("ReplicatedStorage")

---> @Section Custom module items
-------------

local moduleitem = {}
moduleitem.__index = moduleitem

function moduleitem:get()
    return require(self.Module)
end

---> @Section Get modules
-------------

local quickData = {
    modules = {
        ["Data handler"] = setmetatable({
            Description = "Data handler",
            Module = script.Parent.dataHandler.dataHandler,
        }, moduleitem),
        ["Data parser"] = setmetatable({
            Description = "Player data parser",
            Module = script.Parent.dataHandler.playerData,
        }, moduleitem),
        ["Log system"] = setmetatable({
            Description = "Quick and easy way to log your script-contexts",
            Module = ReplicatedStorage.Modules.logger.logger
        }, moduleitem),
        ["House"] = setmetatable({
            Description = "House instance and handler",
            Module = script.Parent.housing.house
        }, moduleitem),
        ["Types"] = setmetatable({
            Description = "House instance and handler",
            Module = script.Parent.types.types
        }, moduleitem),
        ["Housing"] = setmetatable({
            Description = "Housing system for server",
            Module = script.Parent.housing.housing
        }, moduleitem)
    }
}

function quickData:findModule(name : string)
    for idx, module_item in pairs(self.modules) do
        if idx == name then
            --> Matched
            return module_item
        end
    end
end

function quickData:addModule(module : ModuleScript, name : string?, desc : string?)
    self.modules[name or module.Name] = setmetatable({
        Description = desc,
        Module = module
    }, moduleitem)
end

function quickData:getQuickIndex(idx, val)
    return if typeof(val) == "Instance" then val.Name else idx
end

function quickData:copyConfigurationData(ouput, input, toCopy)
    for slowIdx, val in pairs(input) do
        local quickIndex = self:getQuickIndex(slowIdx, val)
        if toCopy and toCopy[quickIndex] then
            ouput[quickIndex] = val.Value
        elseif(ouput[quickIndex]) then
            ouput[quickIndex] = val.Value
        end
    end
end

return quickData