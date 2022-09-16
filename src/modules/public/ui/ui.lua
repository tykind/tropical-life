--> @Desc Userinterface library
--> @Author Tykind
local TweenService = game:GetService("TweenService")

local uilib = {
    MappedNames = {
        ['BT'] = {
            'Frame',
            'ImageLabel',
            'ImageButton',
            'TextBox',
            'TextButton',
            'TextLabel'
        },
        ['IT'] = {
            'ImageLabel',
            'ImageButton'
        },
        ['TT'] = {
            'TextBox',
            'TextButton',
            'TextLabel'
        },
        ['ST'] = {
            -- Fuck you roblox, I hate you
            'ScrollingFrame'
        },
        ['T'] = {
            'UIStroke'
        }
    }
}

function uilib:playTween(speed : number, object : Instance, direction : Enum, prop : any, sync : boolean)
	local Tween = TweenService:Create(object, TweenInfo.new(speed, Enum.EasingStyle.Quad, direction, 0, false), prop)
	Tween:Play()
end

function uilib:checkKnownType(object : GuiObject, mappedTypes : {[number] : string})
    local ret
    for _, typeName in pairs(mappedTypes) do
		if(object.ClassName == typeName) then
			ret = true
            break
		end
	end
	return ret
end

function uilib:changeUIObjectTransparency(object : GuiObject, transparency : number, speed : number?, direction : Enums?, sync : boolean)
        local NoBT, Err = pcall(function()
            return object['transparency ignore']
        end)
        if((not NoBT) and self:checkKnownType(object, self.MappedNames['BT'])) then
            self:playTween(speed or 1, object, direction or Enum.EasingDirection.InOut, {BackgroundTransparency = transparency}, sync)
        end

        if(self:checkKnownType(object, self.MappedNames['IT'])) then
            self:playTween(speed or 1, object, direction or Enum.EasingDirection.InOut, {ImageTransparency = transparency}, sync)
        end

        if(self:checkKnownType(object, self.MappedNames['TT'])) then
            self:playTween(speed or 1, object, direction or Enum.EasingDirection.InOut, {TextTransparency = transparency}, sync)
        end

        if(self:checkKnownType(object, self.MappedNames['T'])) then
            self:playTween(speed or 1, object, direction or Enum.EasingDirection.InOut, {Transparency = transparency}, sync)
        end
        
        if(self:checkKnownType(object, self.MappedNames['ST'])) then
            self:playTween(speed or 1, object, direction or Enum.EasingDirection.InOut, {ScrollBarImageTransparency = transparency}, sync)
        end
end

function uilib:changeGroupTransparency(group : GuiObject, transparency : number, speed : number?, sync : boolean, direction : Enums?)
	for _, object in next, group:GetDescendants() do
        task.spawn(self.changeUIObjectTransparency, self,
             object, transparency, speed, direction)
	end
    self:changeUIObjectTransparency(group, transparency, speed, direction)
end

return uilib