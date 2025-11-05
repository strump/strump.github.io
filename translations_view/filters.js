function update_columns_visibility() {
    var unchecked = [];
    for(var inp of document.querySelectorAll(".filter_form .column_check input")) {
        if (inp.checked == false) {
            unchecked.push(inp.name.substr(4));
        }
    }
    var css_code = "";
    for(var col_id of unchecked) {
        css_code += ".translations td[data-twine-lang=\""+col_id+"\"] {" +
                    "    display: none;" +
                    "}" +
                    ".translations th[data-twine-lang=\""+col_id+"\"] {" +
                    "    display: none;" +
                    "}";
    }

    document.getElementById("columns_style").innerHTML = css_code;
}
function init_listeners() {
    for(var inp of document.querySelectorAll(".filter_form .column_check input")) {
        inp.addEventListener("change", update_columns_visibility);
    }
}
