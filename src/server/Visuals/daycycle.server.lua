--> @Desc Day and night cycle
--> @Author Tykind
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local function tweenTime(to : number, speed : number?, sync : boolean?)
    local Tween = TweenService:Create(Lighting, TweenInfo.new(speed), {
        ClockTime = Lighting.ClockTime + to
    })

    Tween:Play()
    if sync then
        Tween.Completed:Wait()
    end
end

--> @Note Run day and night cycle
while true do task.wait(65)
    tweenTime(.5, .5)
end