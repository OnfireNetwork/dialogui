local web = CreateWebUI(0, 0, 0, 0, 1, 16)
SetWebAlignment(web, 0, 0)
SetWebAnchors(web, 0, 0, 1, 1)
SetWebURL(web, "http://asset/dialogui/dialog.html")
local nextId = 1
local dialogs = {}
local lastOpened = -1
local globalTheme = "default-dark"
function createDialog(title, text, ...)
    local id = nextId
    nextId = nextId + 1
    dialogs[id] = {
        title = title,
        text = text,
        columns = { { inputs = {}, buttons = {} } },
        buttons = {...},
        variables = {},
        autoclose = "true"
    }
    return id
end
function setDialogButtons(dialog, column, ...)
    if dialogs[dialog] == nil then
        return
    end
    if column == 0 then
        dialogs[dialog].buttons = {...}
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
    for k,v in pairs(options) do
        if type(k) == "number" then
            options[tostring(k)] = options[k]
            options[k] = nil
        end
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
function setDialogAutoclose(dialog, autoclose)
    if dialogs[dialog] == nil then
        return
    end
    if autoclose then
        dialogs[dialog].autoclose = "true"
    else
        dialogs[dialog].autoclose = "false"
    end
end
function replaceVariables(text, variables)
    for k,v in pairs(variables) do
        text = text:gsub("{"..k.."}", v)
    end
    return text
end
function closeDialog()
    if dialogs[lastOpened].theme ~= nil then
        applyTheme(globalTheme)
    end
    lastOpened = -1
    ExecuteWebJS(web, "CloseDialog();");
    SetIgnoreLookInput(false)
    SetIgnoreMoveInput(false)
    ShowMouseCursor(false)
    SetInputMode(INPUT_GAME)
end
function destroyDialog(dialog)
    if lastOpened == dialog then
        closeDialog()
    end
    dialogs[dialog] = nil
end
function showDialog(dialog)
    if dialogs[dialog] == nil then
        return
    end
    lastOpened = dialog
    if dialogs[dialog].theme ~= nil then
        applyTheme(dialogs[dialog].theme)
    else
        applyTheme(globalTheme)
    end
    local d = dialogs[dialog]
    local json = {
        autoclose = d.autoclose == "true",
        columns = {},
        buttons = {}
    }
    if d.title ~= nil then
        json["title"] = replaceVariables(d.title, d.variables)
    end
    if d.text ~= nil then
        json["text"] = replaceVariables(d.text, d.variables)
    end
    for j=1,#d.columns do
        json.columns[j] = {}
        if d.columns[j].inputs ~= nil then
            json.columns[j].inputs = {}
            for i=1,#d.columns[j].inputs do
                json.columns[j].inputs[i] = {
                    type = d.columns[j].inputs[i].type
                }
                if d.columns[j].inputs[i].name ~= nil then
                    json.columns[j].inputs[i].name = replaceVariables(d.columns[j].inputs[i].name, d.variables)
                end
                if d.columns[j].inputs[i].options ~= nil then
                    json.columns[j].inputs[i].options = {}
                    if d.columns[j].inputs[i].labelMode then
                        for k,v in pairs(d.columns[j].inputs[i].options) do
                            json.columns[j].inputs[i].options[k] = v
                        end
                    else
                        for k=1,#d.columns[j].inputs[i].options do
                            table.insert(json.columns[j].inputs[i].options, d.columns[j].inputs[i].options[k])
                        end
                    end
                end
                if d.columns[j].inputs[i].size ~= nil then
                    json.columns[j].inputs[i].size = d.columns[j].inputs[i].size
                end
            end
        end
        json.columns[j].buttons = {}
        for i=1,#d.columns[j].buttons do
            table.insert(json.columns[j].buttons, replaceVariables(d.columns[j].buttons[i], d.variables))
        end
    end
    for i=1,#d.buttons do
        table.insert(json.buttons, replaceVariables(d.buttons[i], d.variables))
    end
    ExecuteWebJS(web, "SetDialog("..dialog..","..json_encode(json)..");")
    SetIgnoreLookInput(true)
    SetIgnoreMoveInput(true)
    ShowMouseCursor(true)
    SetInputMode(INPUT_GAMEANDUI)
end
function applyTheme(theme)
    ExecuteWebJS(web, "SetTheme(\""..theme.."\");")
end
function setDialogTheme(dialog, theme)
    if dialogs[dialog] == nil then
        return
    end
    if (theme:len() > 5) and (theme:sub(1,5) == "http:") then
        dialogs[dialog].theme = theme
    else
        dialogs[dialog].theme = "themes/"..theme..".css"
    end
end
function setGlobalTheme(theme)
    globalTheme = theme
    if (theme:len() > 5) and (theme:sub(1,5) == "http:") then
        globalTheme = theme
    else
        globalTheme = "themes/"..theme..".css"
    end
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
AddFunctionExport("setAutoClose", setDialogAutoclose)
AddFunctionExport("setGlobalTheme", setGlobalTheme)
AddFunctionExport("setDialogTheme", setDialogTheme)