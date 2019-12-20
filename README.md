# DialogUI
A very simple ui system for basic dialogs in Onset

## Example
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
