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
    Identifier : string?,
    ObjectRef : Model?,
    Owner : Player?,


    setCanPurchase : (self : House, value : boolean) -> nil,
    canBePurchased : (self : House) -> nil,
    setResetFunction : (self : House, resetFunc : (any...) -> () | nil)  -> nil,
    setSetupFunction : (self : House, setupFunc : (any...) -> () | nil) -> nil,
    setOwner : (self : House, target : Player, onceLeft : (any...) -> () | nil) -> nil,
    setPublicConfig : (self : House, name : string, value : any) -> nil,
    generateTax : (self : House) -> nil,
    getTax : (self : House) -> number,
    purchase : (self : House, target : Player, onceLeft : (any...) -> () | nil) -> nil,
    sell : (self : House, target : Player) -> nil
}

export type HousingSystem = {
    Rnd : Random,
    Houses : CoreTypes.Array<House>,

    createHouse : (self : House, object : Model, taxGen : (number) -> (number)) -> House
}

export type HouseConfig = {
    Price : NumberValue,
    Class : StringValue,
    Identifier : StringValue,
    Owner : NumberValue
}

return nil