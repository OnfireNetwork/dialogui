# DialogUI
A very simple ui system for basic dialogs

## Example
```lua
local Dialog = ImportPackage("dialogui")

local test = Dialog.create("New Character", "Choose your character information", "Create", "Cancel")
Dialog.addTextInput(test, "First Name")
Dialog.addTextInput(test, "Last Name")
Dialog.addSelect(test, "Gender", "Male", "Female", "Apache Helicopter")

Delay(1000, function()
  Dialog.show(test)
end)

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
