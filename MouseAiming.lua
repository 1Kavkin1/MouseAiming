-- [[ Nomercy - Mouse Aiming Only ]]

Players = game:GetService("Players")
UserInputService = game:GetService("UserInputService")
RunService = game:GetService("RunService")
LocalPlayer = Players.LocalPlayer
Camera = workspace.CurrentCamera

scriptConnections = {}

local function trackConnection(conn)
    table.insert(scriptConnections, conn)
    return conn
end

-- Основні налаштування Mouse Aiming
mouseAimEnabled = true
mouseAimConn = nil
mouseAimSeatConn = nil

local function getLocalHumanoid()
    local character = LocalPlayer.Character
    return character and character:FindFirstChildOfClass("Humanoid")
end

-- Логіка керування прицілом миші
local function enableMouseAim()
    if mouseAimConn then return end
    
    mouseAimConn = trackConnection(RunService.RenderStepped:Connect(function()
        if not mouseAimEnabled then return end
        
        local mousePos = UserInputService:GetMouseLocation()
        local unitRay = Camera:ViewportPointToRay(mousePos.X, mousePos.Y)
        
        -- Спрямування прицілу або камери за мишкою
        local targetCFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + unitRay.Direction * 1000)
        Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, 0.2)
    end))
end

local function disableMouseAim()
    if mouseAimConn then
        if mouseAimConn.Connected then
            mouseAimConn:Disconnect()
        end
        mouseAimConn = nil
    end
end

local function updateMouseAimState()
    if mouseAimEnabled then
        enableMouseAim()
    else
        disableMouseAim()
    end
end

-- Відстеження посадки у транспорт / зміну персонажа
local function setupSeatWatcher()
    local hum = getLocalHumanoid()
    if not hum then return end
    
    if mouseAimSeatConn then
        mouseAimSeatConn:Disconnect()
        mouseAimSeatConn = nil
    end
    
    mouseAimSeatConn = trackConnection(hum.Seated:Connect(function(isSeated)
        if isSeated then
            updateMouseAimState()
        else
            disableMouseAim()
        end
    end))
end

trackConnection(LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    setupSeatWatcher()
end))

if LocalPlayer.Character then
    setupSeatWatcher()
end

-- Початковий запуск
updateMouseAimState()