function main()
    local httpService = game:GetService("HttpService")
    local orderTable = getgenv().config.order_tbl or {}
    local encodedOrders = ""

    local function encodeOrders()
        encodedOrders = httpService:JSONEncode(orderTable)
    end

    task.spawn(function()
        while true do
            print("hi")
            encodeOrders()
            task.wait()
        end
    end)

    queue_on_teleport([[
        repeat task.wait() until getgenv().config.loadedInGame -- waits until the main script is 100% loaded in
        getgenv().config = getgenv().config or {}
        getgenv().config.order_tbl = game:GetService("HttpService"):JSONDecode(%q) -- Restore table
    ]], encodedOrders)
end
main()
