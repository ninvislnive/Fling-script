local p,U,S,V,W,plr,char,hrp,ws,cam,uis,rs,run,ts,cs,tp,http,vu,cf,ang,vec3,vec2,clr,twn,tbl,ins,del,deb={},game,game,game,game,game,game,game,game,game,game,game,game,game,game,game,game,game,game,game,game,game,game,game,game,game,game,game,game,game,game
local T=function(s)return S(s)end
local P=T("Players")
local LP=P.LocalPlayer
local function c()return LP.Character or LP.CharacterAdded:Wait()end
local function r()return c():FindFirstChild("HumanoidRootPart")end
local function h()return c():FindFirstChild("Humanoid")end
local function getRemotes()
    local rems={}
    for _,v in ipairs(game:GetDescendants())do if v:IsA("RemoteEvent")then rems[v.Name]=v elseif v:IsA("RemoteFunction")then rems[v.Name]=v end end
    return rems
end
-- GUI
local gui=Instance.new("ScreenGui")
gui.Parent=game.CoreGui
gui.Name="CosmicMenu"
local main=Instance.new("Frame",gui)
main.Size=UDim2.new(0,300,0,400)
main.Position=UDim2.new(0,10,0,10)
main.BackgroundColor3=Color3.fromRGB(15,15,15)
main.BorderSizePixel=0
main.Active=true
main.Draggable=true
local title=Instance.new("TextLabel",main)
title.Size=UDim2.new(1,0,0,30)
title.Text="КОСМИЧЕСКОЕ МЕНЮ | SWILL"
title.BackgroundColor3=Color3.fromRGB(30,30,30)
title.TextColor3=Color3.fromRGB(255,255,255)
title.BorderSizePixel=0
title.Font=Enum.Font.SourceSansBold
title.TextSize=14
local scroll=Instance.new("ScrollingFrame",main)
scroll.Size=UDim2.new(1,0,1,-30)
scroll.Position=UDim2.new(0,0,0,30)
scroll.CanvasSize=UDim2.new(0,0,0,800)
scroll.ScrollBarThickness=5
scroll.BackgroundTransparency=1
local list=Instance.new("UIListLayout",scroll)
list.Padding=UDim.new(0,4)
list.SortOrder=Enum.SortOrder.LayoutOrder
-- Функции
local SET={AntiGrab=false,Fly=false,NoClip=false,InfJump=false,Speed=16,Jump=50,FlingPower=5000,ESP=false,ServerHopTime=60}
local lastHop=tick()
local function addButton(text,cb)
    local btn=Instance.new("TextButton",scroll)
    btn.Size=UDim2.new(1,-10,0,25)
    btn.Text=text
    btn.BackgroundColor3=Color3.fromRGB(50,50,50)
    btn.TextColor3=Color3.fromRGB(255,255,255)
    btn.BorderSizePixel=0
    btn.Font=Enum.Font.SourceSans
    btn.TextSize=14
    btn.MouseButton1Click:Connect(cb)
end
-- 1. AntiGrab
addButton("[Anti-Grab] Нельзя схватить",function()
    SET.AntiGrab=not SET.AntiGrab
end)
-- 2. Fling All
addButton("[Fling All] Кинуть ВСЕХ далеко",function()
    local rems=getRemotes()
    local found=nil
    for n,r in pairs(rems)do if string.find(string.lower(n),"fling")or string.find(string.lower(n),"throw")or string.find(string.lower(n),"yeet")then found=r;break end end
    if not found then return end
    for _,pl in ipairs(P:GetPlayers())do
        if pl~=LP and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart")then
            local args={pl,SET.FlingPower}
            found:FireServer(unpack(args))
        end
    end
end)
-- 3. Fling Single (выбор игрока)
local function updatePlayerList()
    for _,b in ipairs(scroll:GetChildren())do if b.Name=="PlayerBtn"then b:Destroy()end end
    for _,pl in ipairs(P:GetPlayers())do
        if pl~=LP then
            local btn=Instance.new("TextButton",scroll)
            btn.Name="PlayerBtn"
            btn.Size=UDim2.new(1,-10,0,25)
            btn.Text="Fling: "..pl.Name
            btn.BackgroundColor3=Color3.fromRGB(80,40,40)
            btn.TextColor3=Color3.fromRGB(255,255,255)
            btn.BorderSizePixel=0
            btn.Font=Enum.Font.SourceSans
            btn.TextSize=13
            btn.MouseButton1Click:Connect(function()
                local rems=getRemotes()
                local found=nil
                for n,r in pairs(rems)do if string.find(string.lower(n),"fling")or string.find(string.lower(n),"throw")then found=r;break end end
                if found and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart")then
                    found:FireServer(pl,SET.FlingPower)
                end
            end)
        end
    end
end
addButton("[Обновить список игроков]",updatePlayerList)
-- 4. Fly
addButton("[Fly] Летать",function()
    SET.Fly=not SET.Fly
end)
-- 5. NoClip
addButton("[NoClip] Ходить сквозь стены",function()
    SET.NoClip=not SET.NoClip
end)
-- 6. Speed
addButton("[Speed] Увеличить скорость (50)",function()
    local hum=h()
    if hum then hum.WalkSpeed=50 end
end)
-- 7. Jump
addButton("[Jump] Мега-прыжок (150)",function()
    local hum=h()
    if hum then hum.JumpPower=150 end
end)
-- 8. Inf Jump
addButton("[Inf Jump] Бесконечный прыжок",function()
    SET.InfJump=not SET.InfJump
end)
-- 9. ESP
addButton("[ESP] Видеть игроков",function()
    SET.ESP=not SET.ESP
end)
-- 10. Server Hop
addButton("[Server Hop] Сменить сервер",function()
    local http=game:GetService("HttpService")
    local tp=game:GetService("TeleportService")
    local id=game.PlaceId
    local job=game.JobId
    local srvs={}
    local cursor=""
    repeat
        local url="https://games.roblox.com/v1/games/"..id.."/servers/Public?limit=100&cursor="..cursor
        local ok,res=pcall(function()return http:JSONDecode(game:HttpGet(url))end)
        if not ok then break end
        for _,s in ipairs(res.data)do
            if s.playing<s.maxPlayers and s.id~=job then
                table.insert(srvs,s.id)
            end
        end
        cursor=res.nextPageCursor or""
    until cursor==""or #srvs>=10
    if #srvs>0 then
        tp:TeleportToPlaceInstance(id,srvs[math.random(1,#srvs)],LP)
    end
end)
-- 11. Auto Farm
addButton("[Auto Farm] Авто-кидать всех",function()
    while task.wait(0.5)do
        if not SET.AutoFarm then break end
        local rems=getRemotes()
        local found=nil
        for n,r in pairs(rems)do if string.find(string.lower(n),"fling")or string.find(string.lower(n),"throw")then found=r;break end end
        if found then
            for _,pl in ipairs(P:GetPlayers())do
                if pl~=LP and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart")then
                    found:FireServer(pl,SET.FlingPower)
                end
            end
        end
    end
end)
-- 12. Fling Power
addButton("[Fling Power] +1000",function()
    SET.FlingPower=SET.FlingPower+1000
end)
addButton("[Fling Power] -1000",function()
    SET.FlingPower=math.max(100,SET.FlingPower-1000)
end)
-- Циклы функций
run=game:GetService("RunService")
run.Stepped:Connect(function()
    local char=c()
    local hum=h()
    local root=r()
    if not char or not hum or not root then return end
    -- AntiGrab
    if SET.AntiGrab then
        for _,v in ipairs(char:GetDescendants())do if v:IsA("BasePart")then v.CanCollide=false end end
        -- удаляем чужие привязки
        for _,att in ipairs(char:GetChildren())do
            if att:IsA("Attachment")or att:IsA("Weld")or att:IsA("Motor6D")then
                local ok=pcall(function()att:Destroy()end)
            end
        end
        if root:FindFirstChild("BodyVelocity")then root.BodyVelocity:Destroy()end
        local bv=Instance.new("BodyVelocity",root)
        bv.Velocity=Vector3.new(0,0,0)
        bv.MaxForce=Vector3.new(1e5,1e5,1e5)
    end
    -- Fly
    if SET.Fly then
        local speed=50
        local dir=Vector3.new()
        local uis=game:GetService("UserInputService")
        if uis:IsKeyDown(Enum.KeyCode.W)then dir=dir+(workspace.CurrentCamera.CFrame.LookVector)end
        if uis:IsKeyDown(Enum.KeyCode.S)then dir=dir+(-workspace.CurrentCamera.CFrame.LookVector)end
        if uis:IsKeyDown(Enum.KeyCode.A)then dir=dir+(-workspace.CurrentCamera.CFrame.RightVector)end
        if uis:IsKeyDown(Enum.KeyCode.D)then dir=dir+(workspace.CurrentCamera.CFrame.RightVector)end
        if uis:IsKeyDown(Enum.KeyCode.Space)then dir=dir+Vector3.new(0,1,0)end
        if uis:IsKeyDown(Enum.KeyCode.LeftShift)then dir=dir+Vector3.new(0,-1,0)end
        local bf=root:FindFirstChild("BodyVelocity")or Instance.new("BodyVelocity",root)
        bf.Velocity=dir*speed
        bf.MaxForce=Vector3.new(1e5,1e5,1e5)
        hum.PlatformStand=true
    else
        if root:FindFirstChild("BodyVelocity")then root.BodyVelocity:Destroy()end
        hum.PlatformStand=false
    end
    -- NoClip
    if SET.NoClip then
        for _,p in ipairs(char:GetDescendants())do if p:IsA("BasePart")then p.CanCollide=false end end
    end
    -- InfJump
    if SET.InfJump then
        if uis:IsKeyDown(Enum.KeyCode.Space)then
            hum.Jump=true
        end
    end
    -- ESP
    if SET.ESP then
        for _,pl in ipairs(P:GetPlayers())do
            if pl~=LP and pl.Character and pl.Character:FindFirstChild("Head")then
                local head=pl.Character.Head
                if not head:FindFirstChild("ESPBillboard")then
                    local bb=Instance.new("BillboardGui",head)
                    bb.Name="ESPBillboard"
                    bb.Adornee=head
                    bb.Size=UDim2.new(0,100,0,30)
                    bb.AlwaysOnTop=true
                    local tl=Instance.new("TextLabel",bb)
                    tl.Text=pl.Name
                    tl.Size=UDim2.new(1,0,1,0)
                    tl.BackgroundTransparency=1
                    tl.TextColor3=Color3.fromRGB(255,50,50)
                    tl.TextStrokeTransparency=0
                    tl.TextSize=14
                end
            end
        end
    else
        for _,pl in ipairs(P:GetPlayers())do
            if pl.Character and pl.Character:FindFirstChild("Head"):FindFirstChild("ESPBillboard")then
                pl.Character.Head.ESPBillboard:Destroy()
            end
        end
    end
end)
print("Метка: SWILL – Космическое меню активировано")
