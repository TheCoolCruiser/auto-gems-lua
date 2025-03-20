function main()
    repeat task.wait() until game:IsLoaded()
    task.wait(30)

    local save = require(game:GetService("ReplicatedStorage").Library.Client.Save)
    local plrs = game:GetService("Players")
    local plr = plrs.LocalPlayer
    local httpservice = game:GetService("HttpService")
    local teleportService = game:GetService("TeleportService")
    local uri = "wss://mu34t59h5d.execute-api.us-east-1.amazonaws.com/production/?auth_token=ZKWtpPxqUehMUPJU5ZfZ"

    local ws
    local game_name

    if game.PlaceId == 18901165922 then
        game_name = "Pets Go"
    elseif game.PlaceId == 8737899170 then
        game_name = "PS99"
    end


    local function claim_event()
        game:GetService("ReplicatedStorage").Network["Mailbox: Claim All"]:InvokeServer()
    end

    task.spawn(function()
        while true do
            claim_event()
            task.wait(1)
        end
    end)

    local function antiAfk()
        for i,v in getconnections(plr.Idled) do
            v:Disable()
        end
        local vu = game:GetService("VirtualUser")
        while task.wait(60) do
            vu:CaptureController()
            vu:ClickButton2(Vector2.new())
            vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
            task.wait(5)
            vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
        end
    end
    task.spawn(antiAfk)

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

    local function send_webhook(username, amount)
        local data = {
            ["embeds"] = {{
                ["title"] = "Sent gems",
                ["description"] = "",
                ["type"] = "rich",
                ["color"] = 0xffffff,  -- Default color (white)
                ["fields"] = {{
                    ["name"] = "Withdrawer Username:",
                    ["value"] = username,
                    ["inline"] = false
                }, {
                    ["name"] = "Diamonds Amount:",
                    ["value"] = tostring(amount),
                    ["inline"] = false
                }}
            }}
        }
        -- Convert table to JSON
        data = httpservice:JSONEncode(data)

        -- Make the HTTP POST request
        local s, r = request({
            Url = getgenv().config.webhook,
            Method = "POST",
            Headers = {
                ['Content-Type'] = "application/json"
            },
            Body = data
        })

        -- Print the response status and message
        print("Webhook response:", s.StatusMessage, s.StatusCode, r)
    end


    local function send_gems(playerName, gems_amount)

        print(playerName, gems_amount, plr.Name)

        local args = {
            [1] = playerName,
            [2] = getgenv().config.sending_message,
            [3] = "Currency",
            [4] = get_diamond_id(),
            [5] = gems_amount
        }
        local i,v = game:GetService("ReplicatedStorage").Network:FindFirstChild("Mailbox: Send"):InvokeServer(unpack(args))
        print("Mailbox log: ", i,v)
        if i then
            send_webhook(playerName, gems_amount)
        end
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

    -- function optimize()
    --     for i, thing in workspace:GetChildren() do
    --         if thing.Name == plr.Name or thing.Name:lower():find("map") then
    --             continue
    --         end
    --         for _, map in workspace
    --     end
    -- end 



    -- local uri = "ws://10.0.2.2:8765"

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
                ["script"] = "withdraw",
                ["diamonds"] = get_diamond_am()
            }
        }
        ws:Send(httpservice:JSONEncode(connect_data))

        print("connected")

        local onMsgConn = ws.OnMessage:Connect(function(data)
            local data = httpservice:JSONDecode(data)
            data = data["message"]
            print("data received ", data)

            if data["type"] == "withdraw_order" then
                local username = data["customer"]
                local amount = data["amount"]
                local alt_sending = data["alt_username"]
                local order_id = data["order_id"]
                if alt_sending == plr.Name then
                    local status, v = send_gems(username, amount)
                    if status then
                        local withdraw_data = {
                            action="sendmessage",
                            message={
                                type="withdraw_confirmation",
                                ["order_id"] = order_id,
                                game_message = v
                            }
                        }
                        ws:Send(httpservice:JSONEncode(withdraw_data))
                    else
                        local withdraw_data = {
                            action="sendmessage",
                            message={
                                type="withdraw_error",
                                ["order_id"] = order_id,
                                game_message = v
                            }
                        }
                        ws:Send(httpservice:JSONEncode(withdraw_data))
                    end
                end
            elseif data["type"] == "ping" and data["username"] == plr.Name then
                print("Received ping")
                local pong_data = {
                    ["action"] = "sendmessage",
                    ["message"] = {
                        ["type"] = "pong",
                        ["username"] = plr.Name,
                        ["diamonds"] = get_diamond_am(),
                        ["game"] = game_name
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

    local function serializeTable(tbl)
        local result = "{"
        for k, v in pairs(tbl) do
            local key = type(k) == "string" and string.format("[%q]", k) or string.format("[%d]", k)
            local value
            if type(v) == "string" then
                value = string.format("%q", v) -- Properly format strings
            elseif type(v) == "table" then
                value = serializeTable(v) -- Recursively serialize tables
            else
                value = tostring(v)
            end
            result = result .. key .. "=" .. value .. ","
        end
        return result .. "}"
    end
    
    local serializedConfig = serializeTable(getgenv().config)

    queue_on_teleport([[
        repeat task.wait() until game:IsLoaded()
        getgenv().config = ]] .. serializedConfig .. [[
        print("New config: ", getgenv().config)
        loadstring(game:HttpGet(getgenv().config.src))()
    ]])
end
main()
