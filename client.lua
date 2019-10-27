local web = CreateWebUI(0, 0, 0, 0, 1, 16)
SetWebAlignment(web, 0, 0)
SetWebAnchors(web, 0, 0, 1, 1)
SetWebURL(web, "http://asset/dialogui/dialog.html")
local nextId = 1
local dialogs = {}
local lastOpened = -1
function createDialog(title, text)
    local id = nextId
    nextId = nextId + 1
    dialogs[id] = {
        title = title,
        text = text,
        columns = {},
        variables = {}
    }
    return id
end
function setDialogButtons(dialog, column, ...)
    if dialogs[dialog] == nil then
        return
    end
    if dialogs[dialog].columns[column] == nil then
        dialogs[dialog].columns[column] = {
            inputs = {},
            buttons = {}
        }
    end
    dialogs[dialog].columns[column].buttons = {...}
end
function addDialogSelect(dialog, column, label, size, ...)
    if dialogs[dialog] == nil then
        return
    end
    if dialogs[dialog].columns[column] == nil then
        dialogs[dialog].columns[column] = {
            inputs = {},
            buttons = {}
        }
    end
    table.insert(dialogs[dialog].columns[column].inputs, {
        type = "select",
        name = label,
        size = size,
        labelMode = false,
        options = {...}
    })
    return #dialogs[dialog].columns[column].inputs
end
function addDialogCheckbox(dialog, column, label)
    if dialogs[dialog] == nil then
        return
    end
    if dialogs[dialog].columns[column] == nil then
        dialogs[dialog].columns[column] = {
            inputs = {},
            buttons = {}
        }
    end
    table.insert(dialogs[dialog].columns[column].inputs, {
        type = "checkbox",
        name = label
    })
    return #dialogs[dialog].columns[column].inputs
end
function setDialogSelectOptions(dialog, column, input, ...)
    if dialogs[dialog] == nil then
        return
    end
    if dialogs[dialog].columns[column] == nil then
        return
    end
    if dialogs[dialog].columns[column].inputs[input] == nil then
        return
    end
    dialogs[dialog].columns[column].inputs[input].labelMode = false
    if dialogs[dialog].columns[column].inputs[input].options == nil then
        return
    end
    dialogs[dialog].columns[column].inputs[input].options = {...}
end
function setDialogSelectOptionsWithLabels(dialog, column, input, options)
    if dialogs[dialog] == nil then
        return
    end
    if dialogs[dialog].columns[column] == nil then
        return
    end
    if dialogs[dialog].columns[column].inputs[input] == nil then
        return
    end
    dialogs[dialog].columns[column].inputs[input].labelMode = true
    if dialogs[dialog].columns[column].inputs[input].options == nil then
        return
    end
    dialogs[dialog].columns[column].inputs[input].options = options
end
function addDialogTextInput(dialog, column, label)
    if dialogs[dialog] == nil then
        return
    end
    if dialogs[dialog].columns[column] == nil then
        dialogs[dialog].columns[column] = {
            inputs = {},
            buttons = {}
        }
    end
    table.insert(dialogs[dialog].columns[column].inputs, {
        type = "text",
        name = label
    })
    return #dialogs[dialog].columns[column].inputs
end
function setVariable(dialog, name, value)
    if dialogs[dialog] == nil then
        return
    end
    dialogs[dialog].variables[name] = value
end
function replaceVariables(text, variables)
    for k,v in pairs(variables) do
        text = text:gsub("{"..k.."}", v)
    end
    return text
end
function closeDialog()
    lastOpened = -1
    ExecuteWebJS(web, "CloseDialog();");
    SetIgnoreLookInput(false)
    SetIgnoreMoveInput(false)
    ShowMouseCursor(false)
    SetInputMode(INPUT_GAME)
end
function destroyDialog(dialog)
    dialogs[dialog] = nil
    if lastOpened == dialog then
        closeDialog()
    end
end
function showDialog(dialog)
    if dialogs[dialog] == nil then
        return
    end
    lastOpened = dialog
    local d = dialogs[dialog]
    local json = ""
    if d.title ~= nil then
        json = "title:\""..replaceVariables(d.title, d.variables).."\","
    end
    if d.text ~= nil then
        json = json.."text:\""..replaceVariables(d.text, d.variables).."\","
    end
    json = json.."columns:["
    if #d.columns > 0 then
        for j=1,#d.columns do
            if j > 1 then
                json = json..",{"
            else
                json = json.."{"
            end
            if d.columns[j].inputs ~= nil then
                json = json.."inputs:["
                for i=1,#d.columns[j].inputs do
                    if i > 1 then
                        json = json..","
                    end
                    json = json.."{type:\""..d.columns[j].inputs[i].type.."\",name:\""..replaceVariables(d.columns[j].inputs[i].name, d.variables).."\""
                    if d.columns[j].inputs[i].options ~= nil then
                        if d.columns[j].inputs[i].labelMode then
                            json = json..",options:{"
                            local firstOne = true
                            for k,v in pairs(d.columns[j].inputs[i].options) do
                                if not firstOne then
                                    json = json..","
                                else
                                    firstOne = false
                                end
                                json = json..k..":\""..v.."\""
                            end
                            json = json.."}"
                        else
                            json = json..",options:["
                            for k=1,#d.columns[j].inputs[i].options do
                                if k > 1 then
                                    json = json..","
                                end
                                json = json.."\""..d.columns[j].inputs[i].options[k].."\""
                            end
                            json = json.."]"
                        end
                    end
                    if d.columns[j].inputs[i].size ~= nil then
                        json = json..",size:"..d.columns[j].inputs[i].size
                    end
                    json = json.."}"
                end
                json = json.."],"
            end
            json = json.."buttons:["
            for i=1,#d.columns[j].buttons do
                if i > 1 then
                    json = json..","
                end
                json = json.."\""..replaceVariables(d.columns[j].buttons[i], d.variables).."\""
            end
            json = json.."]}"
        end
    end
    ExecuteWebJS(web, "SetDialog("..dialog..",{"..json.."]});")
    SetIgnoreLookInput(true)
    SetIgnoreMoveInput(true)
    ShowMouseCursor(true)
    SetInputMode(INPUT_GAMEANDUI)
end
AddEvent("__dialog_system_closed", function()
    lastOpened = -1
    SetIgnoreLookInput(false)
    SetIgnoreMoveInput(false)
    ShowMouseCursor(false)
    SetInputMode(INPUT_GAME)
end)
AddFunctionExport("create", createDialog)
AddFunctionExport("setButtons", setDialogButtons)
AddFunctionExport("addSelect", addDialogSelect)
AddFunctionExport("addTextInput", addDialogTextInput)
AddFunctionExport("addCheckbox", addDialogCheckbox)
AddFunctionExport("setVariable", setVariable)
AddFunctionExport("show", showDialog)
AddFunctionExport("close", closeDialog)
AddFunctionExport("destroy", destroyDialog)
AddFunctionExport("setSelectOptions", setDialogSelectOptions)
AddFunctionExport("setSelectLabeledOptions", setDialogSelectOptionsWithLabels)