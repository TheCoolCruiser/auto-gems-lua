function main()
    local t = {} -- Table to store account information

    local plr = game:GetService("Players").LocalPlayer
    local filePath = "autogems_accounts.json"
    local httpService = game:GetService("HttpService")

    local scrollingFrame

    local function createAccountFrame(username, scriptType)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0.9, 0, 0.1)
        frame.Name = username
        frame.BackgroundColor3 = Color3.new(0.560784, 0.796078, 1)
        frame.Parent = scrollingFrame
        
        local accountText = Instance.new("TextLabel")
        accountText.TextScaled = true
        accountText.Size = UDim2.new(1, 0, 0.5, 0)
        accountText.Position = UDim2.new(0, 0, 0, 0)
        accountText.Text = username .. ": " .. scriptType
        accountText.Parent = frame
        
        local deleteAccount = Instance.new("TextButton")
        deleteAccount.TextScaled = true
        deleteAccount.Text = "Delete"
        deleteAccount.BackgroundColor3 = Color3.new(1, 0.0235294, 0.0705882)
        deleteAccount.Size = UDim2.new(0.5, 0, 0.5, 0)
        deleteAccount.Position = UDim2.new(0, 0, 0.5, 0)
        
        deleteAccount.MouseButton1Click:Connect(function() 
            t[username] = nil
            frame:Destroy()
            print(t)
        end)
        
        deleteAccount.Parent = frame
        
        local changeAccountType = Instance.new("TextBox")
        changeAccountType.Size = UDim2.new(0.5, 0, 0.5)
        changeAccountType.Position = UDim2.new(0.5, 0, 0.5, 0)
        changeAccountType.PlaceholderText = "Change Account Type"
        changeAccountType.TextScaled = true
        
        changeAccountType.FocusLost:Connect(function(enterPressed) 
            if enterPressed then
                local text = changeAccountType.Text
                if text == "deposit" or text == "withdraw" then
                    t[username] = text -- Update the table with the new script type
                    print(t)
                    accountText.Text = username .. ": " .. text
                end
            end
        end)

        changeAccountType.Parent = frame
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "autoGemsGui"
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent = plr:FindFirstChild("PlayerGui") or plr:WaitForChild("PlayerGui")

    scrollingFrame = Instance.new("ScrollingFrame")
    scrollingFrame.Name = "ScrollingFrame"
    scrollingFrame.Size = UDim2.new(0.9, 0, 0.6, 0)
    scrollingFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 10, 0) -- Allow scrolling
    scrollingFrame.Parent = ScreenGui

    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Padding = UDim.new(0.05, 0)
    uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    uiListLayout.Parent = scrollingFrame

    local ManageFrame = Instance.new("Frame")
    ManageFrame.Name = "ManageFrame"
    ManageFrame.Size = UDim2.new(0.9, 0, 0.15, 0)
    ManageFrame.Position = UDim2.new(0.05, 0, 0, 0)
    ManageFrame.Parent = ScreenGui

    local usernameInput = Instance.new("TextBox")
    usernameInput.Name = "username"
    usernameInput.TextScaled = true
    usernameInput.PlaceholderText = "Username/User ID"
    usernameInput.Size = UDim2.new(0.4, 0, 0.5, 0)
    usernameInput.Position = UDim2.new(0, 0, 0, 0)
    usernameInput.Parent = ManageFrame

    local scriptInput = Instance.new("TextBox")
    scriptInput.Name = "scriptType"
    scriptInput.TextScaled = true
    scriptInput.PlaceholderText = "Script Type (withdraw/deposit)"
    scriptInput.Size = UDim2.new(0.4, 0, 0.5, 0)
    scriptInput.Position = UDim2.new(0.5, 0, 0, 0)
    scriptInput.Parent = ManageFrame

    local createButton = Instance.new("TextButton")
    createButton.Name = "createButton"
    createButton.Text = "Create Account"
    createButton.TextScaled = true
    createButton.BackgroundColor3 = Color3.new(0.2, 0.6, 0.2)
    createButton.Size = UDim2.new(0.9, 0, 0.4, 0)
    createButton.Position = UDim2.new(0.05, 0, 0.6, 0)
    createButton.Parent = ManageFrame

    createButton.MouseButton1Click:Connect(function()
        local username = usernameInput.Text
        local scriptText = scriptInput.Text

        if username ~= "" and scriptText ~= "" then
            t[username] = scriptText
            print(t)
            createAccountFrame(username, scriptText)
        end
    end)

    local function initializeTable()
        if isfile and isfile(filePath) then
            local contents = readfile(filePath)
            local decodedJson = httpService:JSONDecode(contents)
            t = decodedJson
        else
            writefile(filePath, "{}") -- Create the file if it doesn't exist
        end
    end

    initializeTable()

    local function updateFile()
        while true do
            if writefile then
                local encodedJson = httpService:JSONEncode(t)
                writefile(filePath, encodedJson)
            end
            task.wait(1)
        end
    end

    task.spawn(updateFile)

    local function frameForEveryAccount()
        for username, scriptType in pairs(t) do
            local existingFrame = scrollingFrame:FindFirstChild(username)
            if not existingFrame then
                createAccountFrame(username, scriptType)
            end
        end
    end

    task.spawn(frameForEveryAccount)

    local UIS = game:GetService("UserInputService")

    local function makeDraggable(frame)
        local dragToggle = nil
        local dragSpeed = 0.05
        local dragStart = nil
        local startPos = nil

        local function updateInput(input)
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end

        frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragToggle = true
                dragStart = input.Position
                startPos = frame.Position
                
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragToggle = false
                    end
                end)
            end
        end)

        frame.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                if dragToggle then
                    updateInput(input)
                end
            end
        end)
    end

    -- Apply the draggable function to the main GUI frame
    makeDraggable(ScreenGui)
end
main()