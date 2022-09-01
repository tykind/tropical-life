local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreTypes = require(ReplicatedStorage.Modules.types["core types"])

---> @Section Data section
export type DataHandlerConfiguration = {
    Global : boolean,
    DataStoreName : string,
    KeyMask : string,

    OnUpdate : (string, any...) -> () | nil,
    Leaderboard : Folder?
}

---> @Section House stuff

export type House = {
    Price : number,
    Class : string?,
    Connections : CoreTypes.Array<RBXScriptConnection>,
    Identifier : string?
}

export type HousingSystem = {
    Rnd : Random,
    Houses : CoreTypes.Array<House>
}

export type HouseConfig = {
    Price : NumberValue,
    Class : StringValue,
    Identifier : StringValue,
    Owner : NumberValue
}

return nil