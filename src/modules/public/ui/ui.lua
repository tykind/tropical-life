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

function uilib:playTween(speed : number, object : Instance, direction : Enum, prop : any)
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

function uilib:changeUIObjectTransparency(object : GuiObject, transparency : number, speed : number?, direction : Enums?)
    coroutine.wrap(function()
        local NoBT, Err = pcall(function()
            return object['transparency ignore']
        end)
        if((not NoBT) and self:checkKnownType(object, self.MappedNames['BT'])) then
            self:playTween(speed or 1, object, direction or Enum.EasingDirection.InOut, {BackgroundTransparency = transparency})
        end

        if(self:checkKnownType(object, self.MappedNames['IT'])) then
            self:playTween(speed or 1, object, direction or Enum.EasingDirection.InOut, {ImageTransparency = transparency})
        end

        if(self:checkKnownType(object, self.MappedNames['TT'])) then
            self:playTween(speed or 1, object, direction or Enum.EasingDirection.InOut, {TextTransparency = transparency})
        end

        if(self:checkKnownType(object, self.MappedNames['T'])) then
            self:playTween(speed or 1, object, direction or Enum.EasingDirection.InOut, {Transparency = transparency})
        end
        
        if(self:checkKnownType(object, self.MappedNames['ST'])) then
            self:playTween(speed or 1, object, direction or Enum.EasingDirection.InOut, {ScrollBarImageTransparency = transparency})
        end
    end)()
end

function uilib:changeGroupTransparency(group : GuiObject, transparency : number, speed : number?, direction : Enums?)
	self:changeUIObjectTransparency(group, transparency, speed, direction)
	for _, object in next, group:GetDescendants() do
		self:changeUIObjectTransparency(object, transparency, speed, direction)
	end
end

return uilib