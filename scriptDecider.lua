function main()
    local depositConfig = getgenv().depositConfig or {
        user_to_send_to = "youraccount",
        gui = false,
        src = "https://raw.githubusercontent.com/TheCoolCruiser/auto-gems-lua/refs/heads/main/deposit-obfuscated.lua",
        src2 = "https://raw.githubusercontent.com/TheCoolCruiser/auto-gems-lua/refs/heads/main/depsoitOrders.lua",
        loadedInGame = false -- DO NOT TOUCH
    }

    local withdrawConfig = getgenv().withdrawConfig or {
        sending_message = "hello there",
        webhook = "https://discord.com/api/webhooks/1312836336540975247/3ngL7IMr5ARbV2nd-pABYaxt5HkNG1szNlJ0TZ4Ww2dzGrz9YIv9GUhXoQPhx6X0vNs2",
        gui = false,
        src = "https://raw.githubusercontent.com/TheCoolCruiser/auto-gems-lua/refs/heads/main/withdraw-obfuscated.lua"
    }

    local depositSource = withdrawConfig.src
    local withdrawSource = depositConfig.src
    local filePath = "autogems_accounts.json"
    local plr = game:GetService("Players").LocalPlayer
    local httpService = game:GetService("HttpService")

    local function decodeFile()
        if isfile(filePath) then
            local file = readfile(filePath)
            local json = httpService:JSONDecode(file)
            print(json)
            return json
        end
    end

    local function decideScript()
        local json = decodeFile()
        if json then
            if json[plr.Name] or json[plr.UserId] then
                local scriptType = json[plr.Name] or json[plr.UserId]
                print(scriptType)
                if scriptType == "deposit" then
                    return scriptType
                elseif scriptType == "withdraw" then
                    return scriptType
                end
            end
        end
    end

    local function runScript()
        local scriptType = decideScript()
        if scriptType == "deposit" then
            loadstring(game:HttpGet(depositSource))()
            getgenv().config = depositConfig
        elseif scriptType == "withdraw" then
            loadstring(game:HttpGet(withdrawSource))()
            getgenv().config = withdrawConfig
        end
    end
    runScript()
end
main()
