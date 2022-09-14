--> @Desc Conveyors handler
-->	@Author Tykind
task.wait(.5)
local Conveyors = workspace.Conveyors

---> @Section Code
local function createConveyors(obj : BasePart, speed : number)
	while true do task.wait()
		obj.AssemblyLinearVelocity = Vector3.new(speed, 0, -speed)
	end
end

for _, conveyor in pairs(Conveyors:GetChildren()) do
	task.spawn(createConveyors, conveyor, 11.3)
end