function SetDialog(id, json) {
    let menuDiv = document.getElementById("menu");
    menuDiv.style.display = "inline-block";
    let inputs = [];
    let nextButtonId = 1;
    while (menuDiv.firstChild !== null) {
        menuDiv.removeChild(menuDiv.firstChild);
    }
    let boxWidth = json.columns.length;
    if(boxWidth < 1){
        boxWidth = 1;
    }
    let menuContentDiv = document.createElement("div");
    menuContentDiv.style.width = (boxWidth*300)+"px";
    if (json.title !== undefined) {
        if(json.title.length > 0){
            let titleH = document.createElement("h1");
            titleH.className = "menu-title";
            titleH.appendChild(document.createTextNode(json.title));
            menuContentDiv.appendChild(titleH);
            menuContentDiv.appendChild(document.createElement("hr"));
        }
    }
    if (json.text !== undefined) {
        if(json.text.length > 0){
            let textSpan = document.createElement("span");
            textSpan.className = "menu-info";
            textSpan.appendChild(document.createTextNode(json.text));
            menuContentDiv.appendChild(textSpan);
            menuContentDiv.appendChild(document.createElement("hr"));
        }
    }
    let gridElement = document.createElement("div");
    gridElement.className = "row";
    gridElement.style.width = (boxWidth*300)+"px";
    gridElement.style.marginLeft = "0px";
    let rendered = 0;
    for(let colId=0; colId<json.columns.length; colId++){
        let column = json.columns[colId];
        let colElement = document.createElement("div");
        switch(json.columns.length){
            case 1:
                colElement.className = "col-md-12 spl-c1-1";
                break;
            case 2:
                colElement.className = "col-md-6 spl-c2-"+(colId+1);
                break;
            case 3:
                colElement.className = "col-md-4 spl-c3-"+(colId+1);
                break;
        }
        if (column.inputs !== undefined && column.inputs.length > 0) {
            for (let jsonInput of column.inputs){
                if (jsonInput.type === "text") {
                    let inputElement = document.createElement("input");
                    inputElement.className = "menu-input-text";
                    if(jsonInput.name.length > 0){
                        let labelElement = document.createElement("label");
                        labelElement.className = "menu-label";
                        labelElement.appendChild(document.createTextNode(jsonInput.name));
                        colElement.appendChild(labelElement);
                        colElement.appendChild(inputElement);
                        rendered++;
                    }
                    inputs.push(inputElement);
                }
                if (jsonInput.type === "select") {
                    let selectElement = document.createElement("select");
                    selectElement.className = "menu-select";
                    if(jsonInput.size !== undefined){
                        selectElement.size = jsonInput.size;
                    }
                    if(Array.isArray(jsonInput.options)){
                        for (let option of jsonInput.options) {
                            let optionElement = document.createElement("option");
                            optionElement.appendChild(document.createTextNode(option));
                            selectElement.appendChild(optionElement);
                        }
                    }else{
                        for (let optionKey of Object.keys(jsonInput.options)) {
                            let optionElement = document.createElement("option");
                            optionElement.appendChild(document.createTextNode(jsonInput.options[optionKey]));
                            optionElement.value = optionKey;
                            selectElement.appendChild(optionElement);
                        }
                    }
                    if(jsonInput.name === undefined || jsonInput.name.length > 0){
                        if(jsonInput.name !== undefined){
                            let labelElement = document.createElement("label");
                            labelElement.className = "menu-label";
                            labelElement.appendChild(document.createTextNode(jsonInput.name));
                            colElement.appendChild(labelElement);
                        }
                        colElement.appendChild(selectElement);
                        rendered++;
                    }
                    inputs.push(selectElement);
                }
                if (jsonInput.type === "checkbox") {
                    let checkboxElement = document.createElement("input");
                    checkboxElement.setAttribute("type", "checkbox");
                    checkboxElement.className = "menu-checkbox";
                    if(jsonInput.name.length > 0){
                        colElement.appendChild(checkboxElement);
                        let labelElement = document.createElement("label");
                        labelElement.className = "menu-label";
                        labelElement.appendChild(document.createTextNode(jsonInput.name));
                        colElement.appendChild(labelElement);
                        colElement.appendChild(document.createElement("br"));
                        rendered++;
                    }
                    inputs.push(checkboxElement);
                }
            }
        }
        gridElement.appendChild(colElement);
    }
    menuContentDiv.appendChild(gridElement);
    if(rendered > 0){
        menuContentDiv.appendChild(document.createElement("hr"));
    }
    gridElement = document.createElement("div");
    gridElement.className = "row";
    gridElement.style.width = (boxWidth*300)+"px";
    gridElement.style.marginLeft = "0px";
    for(let colId=0; colId<json.columns.length; colId++){
        let column = json.columns[colId];
        let colElement = document.createElement("div");
        switch(json.columns.length){
            case 1:
                colElement.className = "col-md-12 spl-c1-1";
                break;
            case 2:
                colElement.className = "col-md-6 spl-c2-"+(colId+1);
                break;
            case 3:
                colElement.className = "col-md-4 spl-c3-"+(colId+1);
                break;
        }
        for (let i = 0; i < column.buttons.length; i++){
            if(column.buttons[i].length == 0){
                continue;
            }
            let buttonElement = document.createElement("button");
            buttonElement.className = "menu-button";
            buttonElement.appendChild(document.createTextNode(column.buttons[i]));
            let buttonId = nextButtonId;
            nextButtonId++;
            buttonElement.onclick = function () {
                let params = [id, buttonId];
                for (let input of inputs) {
                    if (input.type === "checkbox") {
                        params.push(input.checked);
                    } else {
                        params.push(input.value);
                    }
                }
                if(json.autoclose === undefined || json.autoclose){
                    CloseDialog();
                    ue.game.callevent("__dialog_system_closed", "[]");
                }
                ue.game.callevent("OnDialogSubmit", JSON.stringify(params));
            };
            colElement.appendChild(buttonElement);
        }
        gridElement.appendChild(colElement);
    }
    menuContentDiv.appendChild(gridElement);
    for (let i = 0; i < json.buttons.length; i++){
        if(json.buttons[i].length == 0){
            continue;
        }
        let buttonElement = document.createElement("button");
        buttonElement.className = "menu-button";
        buttonElement.appendChild(document.createTextNode(json.buttons[i]));
        let buttonId = nextButtonId;
        nextButtonId++;
        buttonElement.onclick = function () {
            let params = [id, buttonId];
            for (let input of inputs) {
                if (input.type === "checkbox") {
                    params.push(input.checked);
                } else {
                    params.push(input.value);
                }
            }
            if(json.autoclose === undefined || json.autoclose){
                CloseDialog();
                ue.game.callevent("__dialog_system_closed", "[]");
            }
            ue.game.callevent("OnDialogSubmit", JSON.stringify(params));
        };
        menuContentDiv.appendChild(buttonElement);
    }
    menuDiv.appendChild(menuContentDiv);
}

function CloseDialog() {
    let menuDiv = document.getElementById("menu");
    menuDiv.style.display = "none";
}