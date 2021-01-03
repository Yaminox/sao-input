local promiseList = {}
local promiseID = 1

function TextInput(description, maxLength)
    local currentMax = promiseID
    promiseID = promiseID + 1
    local id = promiseID
    promiseList[id] = {promise:new(), 'Input', description, maxLength, id}

    if not promiseList[id -1] then
        OpenUI('Input', description, maxLength, id)
    end

    return Citizen.Await(promiseList[id][1])
end

function Confirm(title, description)
    local currentMax = promiseID
    promiseID = promiseID + 1
    local id = promiseID
    promiseList[id] = {promise:new(), 'Confirm', title, description, id}

    if not promiseList[id -1] then
        OpenUI('Confirm', title, description, id)
    end

    return Citizen.Await(promiseList[id][1])
end

function OpenUI(guiType, description, maxLength, id)
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = guiType,
        description = description,
        length = maxLength,
        id = id
    })
end

RegisterNUICallback('TextInput', function(data)
    if promiseList[data.id] then
        SetNuiFocus(false, false)
        promiseList[data.id][1]:resolve(data.text)
        promiseList[data.id] = nil

        if promiseList[data.id + 1] then
            Wait(500)
            OpenUI(table.unpack(promiseList[data.id + 1], 2, 5))
        end
    end
end)

exports('TextInput', TextInput)
exports('Confirm', Confirm)