# DialogUI
A very simple ui system for basic dialogs in Onset

## Example
*!!! Make sure to put dialogui before your gamemode in server_config.json or it won't work !!!*
```lua
local Dialog = ImportPackage("dialogui")

local test = Dialog.create("New Character", "Choose your character information", "Create", "Cancel")
Dialog.addTextInput(test, 1, "First Name:")
Dialog.addTextInput(test, 1, "Last Name:")
Dialog.addSelect(test, 1, "Gender:", 1, "Male", "Female", "Apache Helicopter")

Dialog.show(test)

AddEvent("OnDialogSubmit", function(dialog, button, firstName, lastName, gender)
  if dialog ~= test then
    return
  end
  if button == 1 then
    AddPlayerChat("Character created:")
    AddPlayerChat("First Name = "..firstName)
    AddPlayerChat("Last Name = "..lastName)
    AddPlayerChat("Gender = "..gender)
  else
    AddPlayerChat("Cancelled character creation!")
  end
end)
```
![image](/screenshots/character-menu.png)

## Available functions
```lua
create(title, text, ...buttons)
setButtons(dialog, column, ...buttons)
addTextInput(dialog, column, label)
addSelect(dialog, column, label, size, ...options)
setSelectOptions(dialog, column, input, ...options)
setSelectLabeledOptions(dialog, column, input, options)
addCheckbox(dialog, column, label)
setVariable(dialog, name, value)
setAutoclose(dialog, autoclose)
show(dialog)
close()
destroy(dialog)
getCurrent()
isVisible()
setDialogTheme(dialog, theme)
setGlobalTheme(theme)
```

## Variables
In some strings you may use variables to dynamically change parts of the text of certain dialogs. This may also be used to dynamically hide or display buttons because buttons with a length of 0 aren't displayed. The syntax for variables is `{some_variable}`

## Themes
There are multiple themes and you can create your own ones.
- default-dark
- saitama
- flat

To set the global theme:
```lua
Dialog.setGlobalTheme("flat")
```
To set a theme for just one dialog
```lua
Dialog.setDialogTheme(dialog, "flat")
```
