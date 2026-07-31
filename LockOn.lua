local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local me = Players.LocalPlayer
local locked = false
local uiLocked = false
local target
local range = 50

-- สร้าง UI
local gui = Instance.new("ScreenGui")
gui.Name = "LockOnUI"
gui.ResetOnSpawn = false
gui.Parent = me:WaitForChild("PlayerGui")

local box = Instance.new("Frame")
box.Size = UDim2.fromOffset(220, 145)
box.Position = UDim2.fromOffset(20, 100)
box.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
box.Active = true
box.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = box

-- ปุ่มล็อก UI
local uiLockButton = Instance.new("TextButton")
uiLockButton.Size = UDim2.fromOffset(35, 30)
uiLockButton.Position = UDim2.fromOffset(180, 5)
uiLockButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
uiLockButton.TextColor3 = Color3.fromRGB(255, 255, 255)
uiLockButton.TextSize = 18
uiLockButton.Text = "🔓"
uiLockButton.Parent = box

local lockCorner = Instance.new("UICorner")
lockCorner.CornerRadius = UDim.new(0, 6)
lockCorner.Parent = uiLockButton

uiLockButton.MouseButton1Click:Connect(function()
	uiLocked = not uiLocked

	if uiLocked then
		uiLockButton.Text = "🔒"
		uiLockButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
	else
		uiLockButton.Text = "🔓"
		uiLockButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	end
end)

-- ปุ่ม Lock On
local lockBtn = Instance.new("TextButton")
lockBtn.Size = UDim2.fromOffset(190, 50)
lockBtn.Position = UDim2.fromOffset(15, 10)
lockBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
lockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
lockBtn.TextSize = 20
lockBtn.Font = Enum.Font.GothamBold
lockBtn.Text = "LOCK: OFF"
lockBtn.Parent = box

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 8)
buttonCorner.Parent = lockBtn

-- แสดงระยะ
local rangeText = Instance.new("TextLabel")
rangeText.Size = UDim2.fromOffset(100, 35)
rangeText.Position = UDim2.fromOffset(60, 65)
rangeText.BackgroundTransparency = 1
rangeText.TextColor3 = Color3.fromRGB(255, 255, 255)
rangeText.TextSize = 18
rangeText.Text = "RANGE: 50"
rangeText.Parent = box

-- ปุ่มลดระยะ
local minus = Instance.new("TextButton")
minus.Size = UDim2.fromOffset(45, 35)
minus.Position = UDim2.fromOffset(10, 65)
minus.Text = "−"
minus.TextSize = 25
minus.Parent = box

-- ปุ่มเพิ่มระยะ
local plus = Instance.new("TextButton")
plus.Size = UDim2.fromOffset(45, 35)
plus.Position = UDim2.fromOffset(165, 65)
plus.Text = "+"
plus.TextSize = 25
plus.Parent = box

-- ชื่อผู้ทำ
local credit = Instance.new("TextLabel")
credit.Size = UDim2.fromOffset(200, 25)
credit.Position = UDim2.fromOffset(10, 110)
credit.BackgroundTransparency = 1
credit.Text = "by kiyoshi"
credit.TextColor3 = Color3.fromRGB(220, 220, 220)
credit.TextSize = 14
credit.Font = Enum.Font.Gotham
credit.Parent = box

-- ปรับระยะ
minus.MouseButton1Click:Connect(function()
	range = math.max(10, range - 10)
	rangeText.Text = "RANGE: " .. range
end)

plus.MouseButton1Click:Connect(function()
	range = math.min(200, range + 10)
	rangeText.Text = "RANGE: " .. range
end)

-- หา Player และ NPC ที่ใกล้ที่สุด
local function nearest()
	local myChar = me.Character
	local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

	if not myRoot then return nil end

	local closest
	local shortest = range

	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("Model") and obj ~= myChar then
			local hum = obj:FindFirstChildOfClass("Humanoid")
			local root = obj:FindFirstChild("HumanoidRootPart")

			if hum and hum.Health > 0 and root then
				local distance = (myRoot.Position - root.Position).Magnitude

				if distance < shortest then
					closest = obj
					shortest = distance
				end
			end
		end
	end

	return closest
end

-- เปิด/ปิด Lock On
lockBtn.MouseButton1Click:Connect(function()
	locked = not locked

	if locked then
		target = nearest()

		if target then
			lockBtn.Text = "LOCK: ON"
			lockBtn.BackgroundColor3 = Color3.fromRGB(40, 150, 70)
		else
			locked = false
			lockBtn.Text = "NO TARGET"

			task.wait(1)

			lockBtn.Text = "LOCK: OFF"
		end
	else
		target = nil
		lockBtn.Text = "LOCK: OFF"
		lockBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	end
end)

-- ลาก UI
local dragging = false
local dragStart
local startPos

box.InputBegan:Connect(function(input)
	if uiLocked then return end

	if input.UserInputType == Enum.UserInputType.Touch
	or input.UserInputType == Enum.UserInputType.MouseButton1 then

		dragging = true
		dragStart = input.Position
		startPos = box.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

UIS.InputChanged:Connect(function(input)
	if not dragging or uiLocked then return end

	if input.UserInputType == Enum.UserInputType.Touch
	or input.UserInputType == Enum.UserInputType.MouseMovement then

		local delta = input.Position - dragStart

		box.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

-- หันตัวตามเป้าหมาย
RunService.RenderStepped:Connect(function()
	if not locked then return end

	local myChar = me.Character
	local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

	local hum = target and target:FindFirstChildOfClass("Humanoid")
	local targetRoot = target and target:FindFirstChild("HumanoidRootPart")

	-- ถ้าเป้าหมายตาย ให้หาเป้าหมายใหม่
	if not hum or hum.Health <= 0 or not targetRoot then
		target = nearest()

		if not target then
			locked = false
			lockBtn.Text = "LOCK: OFF"
			lockBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
			return
		end

		targetRoot = target:FindFirstChild("HumanoidRootPart")
	end

	-- หันเฉพาะแนวนอน
	if myRoot and targetRoot then
		local lookAt = Vector3.new(
			targetRoot.Position.X,
			myRoot.Position.Y,
			targetRoot.Position.Z
		)

		myRoot.CFrame = CFrame.lookAt(
			myRoot.Position,
			lookAt
		)
	end
end)
