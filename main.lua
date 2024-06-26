local ws = http.websocket("ws://192.168.1.25:5858")
local chatbox = peripheral.find("chatBox")

local json_message = {
    ["username"] = os.getComputerLabel(),
    ["id"] = os.getComputerID(),
    ["act"] = "connect"
}

local raw_message = textutils.serialiseJSON(json_message)
ws.send(raw_message)


local function getChatHandle()
    local event, username, message, uuid, isHidden = os.pullEvent("chat")
    
    local chat_event_message = {
        ["chat-message"] = {
            ["username"] = username,
            ["uuid"] = uuid,
            ["is-hidden"] = isHidden,
            ["message"] = message
        }
    }
    ws.send(textutils.serialiseJSON(chat_event_message))
end

local function handleWebSocket()
    local raw_info = ws.receive()
    local json_info = textutils.unserialiseJSON(raw_info)

    if json_info["success"] ~= false then
        print(json_info)
    elseif json_info["success"] then
        print(json_info)
    end
    local response = {
        ["success"] = false
    }

    if json_info == nil then
        -- This literraly does nothing
    elseif json_info["action"] == "movement" then
        if json_info["type"] == "UP" then
            turtle.up()
            response["success"] = true
        elseif json_info["type"] == "DOWN" then
            turtle.down()
            response["success"] = true
        elseif json_info["type"] == "FORWARD" then
            turtle.forward()
            response["success"] = true
        elseif json_info["type"] == "BACKWARD" then
            turtle.back()
            response["success"] = true
        elseif json_info["type"] == "RIGHT" then
            turtle.turnRight()
            response["success"] = true
        elseif json_info["type"] == "LEFT" then
            turtle.turnLeft()
            response["success"] = true
        end
    elseif json_info["action"] == "inspect" then
        response["success"] = true
        response["block"] = turtle.detect()
    elseif json_info["action"] == "fuel-level" then
        response["success"] = true
        response["fuel-level"] = turtle.getFuelLevel()
    elseif json_info["action"] == "selected-slot" then
        response["success"] = true
        response["slot"] = turtle.getItemDetail(turtle.getSelectedSlot())
    elseif json_info["action"] == "chat" then
        chatbox.sendMessage(json_info["type"], os.getComputerLabel(), "<>")
        response["success"] = true
    end


    -- Sends a response to the client
    ws.send(textutils.serialiseJSON(response))
end

while true do
    parallel.waitForAny(getChatHandle, handleWebSocket)
end