function main()
    repeat task.wait() until game:IsLoaded()
    task.wait(15)
    local plrs = game:GetService("Players")
    local plr = plrs.LocalPlayer
    local rs = game:GetService("ReplicatedStorage")
    local save = require(game:GetService("ReplicatedStorage").Library.Client.Save)
    local httpservice = game:GetService("HttpService")
    local teleportService = game:GetService("TeleportService")
    local uri = "wss://mu34t59h5d.execute-api.us-east-1.amazonaws.com/production/?auth_token=ZKWtpPxqUehMUPJU5ZfZ"
    local encodedConfig = ""
    order_tbl = {}
    local encodedOrderTable = ""

    local ws
    local game_name

    if game.PlaceId == 18901165922 then
        game_name = "Pets Go"
    elseif game.PlaceId == 8737899170 then
        game_name = "PS99"
    end

    local function newMsgConnection()
        print("trying to connect")

        repeat task.wait(1)
            local s
            s,ws = pcall(function() return WebSocket.connect(uri) end)
            if (not s) or (not ws) then
                continue
            end
            print(ws, type(ws))
        until s and ws
        
        local connect_data = {
            ["action"] = "sendmessage",
            ["message"] = {
                ["game"] = game_name,
                ["username"] = plr.Name,
                ["user_id"] = plr.UserId,
                ["type"] = "connect",
                ["script"] = "deposit"
            }
        }

        ws:Send(httpservice:JSONEncode(connect_data))

        print("connected")

        local onMsgConn = ws.OnMessage:Connect(function(message)
            local data = httpservice:JSONDecode(message)
            data = data["message"]
            print("received data", message)

            if data["type"] == "deposit_order" then
                if data["alt_username"] == plr.Name then
                    order_tbl[tostring(data["customer"])] = data["order_id"]
                end
                
            elseif data["type"] == "ping" and data["username"] == plr.Name then
                print("Received ping")
                local pong_data = {
                    ["action"] = "sendmessage",
                    ["message"] = {
                        ["type"] = "pong",
                        ["username"] = plr.Name
                    } 
                }
                ws:Send(httpservice:JSONEncode(pong_data))
                print("Sent pong")
            end
        end)

        ws.OnClose:Connect(function()
            print("ws closed, reconnecting")
            onMsgConn:Disconnect()
            ws = nil
            onMsgConn = nil
            -- newMsgConnection()
        end)

        while ws and onMsgConn and task.wait(1) do
        end
    end
    task.spawn(newMsgConnection)

    -- anti afk game:GetService("ReplicatedStorage").Network:FindFirstChild("Idle Tracking: Stop Timer"):FireServer()

    local function get_username(userid)
        local json = game:HttpGet(string.format("https://users.roblox.com/v1/users/%s", userid))
        local data = httpservice:JSONDecode(json)
        return data["name"]
    end

    local event

    local mailboxRemoteEvent = rs.Network:FindFirstChild("Mailbox: Add History")
    local mailboxBindableEvent = rs.Library.Client.Network:FindFirstChild("Mailbox: Add History")

    if mailboxRemoteEvent and mailboxRemoteEvent:IsA("RemoteEvent") then
        event = mailboxRemoteEvent.OnClientEvent
    elseif mailboxBindableEvent and mailboxBindableEvent:IsA("BindableEvent") then
        event = mailboxBindableEvent.Event
    else
        game.Players.LocalPlayer:Kick("Couldn't find any mailbox event")
    end

    event:Connect(function(i) do
        print("Item received in mailbox")
        local info = {}

        for i2, v2 in i do
            if i.Type == "Recieve" then
                if i.Sender then
                    local depositer = get_username(i.Sender)
                    info["depositer"] = depositer
                end
            end
        end
        for i3, v3 in i.Item do
            print(i3,v3)
            if i.Item.class == "Currency" then
                print("Diamonds confirmed")
            end
            for i4, v4 in i.Item.data do
                if i.Item.data.id == "Diamonds" then
                    info["amount"] = i.Item.data._am
                end
            end
        end

        local depoit_data = {
            ["action"] = "sendmessage",
            ["message"] = {
                ["depositer"] = info["depositer"],
                ["amount"] = info["amount"],
                ["type"] = "deposit_confirmation",
                ["game"] = game_name,
                ["handler_user"] = plr.Name,
                ["order_id"] = 0
            }
        }

        print("checking if the order ID is in the order table")

        if order_tbl[info['depositer']] then
            depoit_data["message"]["order_id"] = order_tbl[info["depositer"]]
            print("Order ID is in the order table!")

            ws:Send(httpservice:JSONEncode(depoit_data)) -- sending the deposit data to the server in a JSON

            order_tbl[info["depositer"]] = nil
        end
    end
    end)

    local function get_diamond_id()
        local func = save.Get()
        for i,v in func.Inventory.Currency do
            print(i, v)
            for _, type in v do
                if type == "Diamonds" then
                    return i
                end
            end
        end
    end

    local function get_diamond_am()
        local saveFile = save.Get()
        for uuid,itemTable in saveFile.Inventory.Currency do
            if itemTable.id == "Diamonds" then
                return itemTable._am
            end
        end
    end

    local function send_gems(playerName, gems_amount)
        local args = {
            [1] = playerName,
            [2] = "hi there",
            [3] = "Currency",
            [4] = get_diamond_id(),
            [5] = gems_amount
        }
        local i,v = game:GetService("ReplicatedStorage").Network:FindFirstChild("Mailbox: Send"):InvokeServer(unpack(args))
        print("Mailbox log: ", i,v)
        return i,v
    end

    local function format_number(num)
        local formatted
        if num >= 1e9 then
            formatted = string.format("%.2fB", num / 1e9)  -- Format billions
        elseif num >= 1e6 then
            formatted = string.format("%.2fm", num / 1e6)  -- Format millions
        elseif num >= 1e3 then
            formatted = string.format("%.2fk", num / 1e3)  -- Format thousands
        else
            formatted = tostring(num)  -- If below 1000, just return the number
        end
        return formatted
    end

    task.spawn(function()
        while true do
            game:GetService("ReplicatedStorage").Network["Mailbox: Claim All"]:InvokeServer()
            task.wait(1)
        end
    end)

    task.spawn(function()
        while true do
            local diamond_am = get_diamond_am()
            if diamond_am and diamond_am >= 10000000000 then
                send_gems(getgenv().config.user_to_send_to, 10000000000)
            end
            task.wait(15)
        end
    end)

    local function rejoin()
        task.wait(1800)
        local PlaceId = game.PlaceId
        teleportService:Teleport(PlaceId, plr)
    end
    task.spawn(rejoin)

    plr.OnTeleport:Connect(function()
        print("Player is being teleported..")
        if ws then
            pcall(function() ws:Close() end) -- Prevent errors
        end
    end)

    local function makegui()
        local screengui = Instance.new("ScreenGui")
        screengui.Name = "gmbl"
        screengui.Parent = plr.PlayerGui
        screengui.IgnoreGuiInset = true

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.Position = UDim2.new(0,0,0,0)
        frame.BackgroundColor3 = Color3.new()
        frame.Parent = screengui

        local image_lbl = Instance.new("ImageLabel")
        image_lbl.Position = UDim2.new(0.35, 0, 0.15, 0)
        image_lbl.BackgroundTransparency = 1
        image_lbl.Image = "http://www.roblox.com/asset/?id=111893702003985"
        image_lbl.Size = UDim2.new(0.3, 0, 0.5, 0)
        image_lbl.Parent = frame

        local text = Instance.new("TextLabel")
        text.BackgroundTransparency = 1
        text.TextColor3 = Color3.new(1, 1, 1)
        local am = get_diamond_am()
        local am = format_number(am)
        text.Text = string.format("@%s\n💎- %s", plr.Name, am)
        text.Position = UDim2.new(0.3, 0, 0.6, 0)
        text.Size = UDim2.new(0.4, 0, 0.3, 0)
        text.TextScaled = true
        text.FontFace = Font.fromEnum(Enum.Font.LuckiestGuy)
        text.Parent = frame
    end

    if getgenv().config.gui then
        makegui()
        task.spawn(function()
            while true do
                task.wait(1)
                local am = get_diamond_am()
                local am = format_number(am)
                local text = plr.PlayerGui:FindFirstChild("gmbl").Frame.TextLabel
                text.Text = string.format("@%s\n💎- %s", plr.Name, am)
            end
        end)
    end

    local function updateSerializedConfig()
        encodedConfig = httpservice:JSONEncode(getgenv().config)
        encodedOrderTable = httpservice:JSONEncode(order_tbl)
    end
    
    -- Periodically update the serialized config
    task.spawn(function()
        while true do
            updateSerializedConfig()
            task.wait(5)  -- Adjust timing as needed
        end
    end)

    queue_on_teleport([[
        repeat task.wait() until game:IsLoaded()
        getgenv().config = game:GetService("HttpService"):JSONDecode("]] .. encodedConfig:gsub("\\", "\\\\"):gsub('"', '\\"') .. [[") or {}
        print("Plr teleported, loaded config")
        loadstring(game:HttpGet(getgenv().config.src))()
    ]])

end
main()
