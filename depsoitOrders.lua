function tableMain()
    if getgenv().executed2 then
        print("Prevented double execution")
        return
    else
        getgenv().executed2 = true
        print("Executed table script")
    end
    local httpService = game:GetService("HttpService")
    local orderTable = getgenv().config.order_tbl or {}
    local encodedOrders = ""
    -- local encodedConfig = httpService:JSONEncode(getgenv().config) -- remove when done

    local function encodeOrders()
        encodedOrders = httpService:JSONEncode(orderTable)
    end

    task.spawn(function()
        while true do
            encodeOrders()
            task.wait(1)
        end
    end)

    queue_on_teleport(string.format([[
        getgenv().config = getgenv().config or {}
        repeat task.wait() until getgenv().config.loadedInGame
        getgenv().config.order_tbl = game:GetService("HttpService"):JSONDecode(%q) -- Restore table
        for i,v in getgenv().config.order_tbl do print(i,v) end
    ]], encodedOrders)) -- encodedConfig, encodedOrders
end
tableMain()
