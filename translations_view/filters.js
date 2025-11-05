function update_columns_visibility() {
    var unchecked = [];
    for(var inp of document.querySelectorAll(".filter_form .column_check input")) {
        if (inp.checked == false) {
            unchecked.push(inp.name.substr(4));
        }
    }
    var css_code = "";
    for(var col_id of unchecked) {
        css_code += ".translations td[data-twine-lang=\""+col_id+"\"] {\n" +
                    "    display: none;\n" +
                    "}\n" +
                    ".translations th[data-twine-lang=\""+col_id+"\"] {\n" +
                    "    display: none;\n" +
                    "}\n";
    }

    document.getElementById("columns_style").innerHTML = css_code;
}

function update_rows_visibility() {
    var keys_filter = get_keys_quick_filter_css();
    var unchecked_tags = [];
    for(var inp of document.querySelectorAll(".filter_form .tag_check input")) {
        if (inp.checked) {
            unchecked_tags.push(inp.name.substr(4));
        }
    }
    var css_code = ".translations tr {display:none;}\n" +
    ".translations tr.header {display:table-row;}\n";
    for(var tag_id of unchecked_tags) {
        css_code += ".translations tr[data-twine-tags*=\","+tag_id+",\"]"+keys_filter+" {\n" +
                    "    display: table-row;\n" +
                    "}\n";
    }

    document.getElementById("rows_style").innerHTML = css_code;
}

function get_keys_quick_filter_css() {
    var filter_input = document.getElementById("keys_quick_filter");
    var search_text = filter_input.value.trim();
    var css_code = "";
    if (search_text.length > 0)
        css_code = "[data-twine-key*=\""+search_text+"\"]";
    return css_code;

}

function init_listeners() {
    for(var inp of document.querySelectorAll(".filter_form .column_check input")) {
        inp.addEventListener("change", update_columns_visibility);
    }
    for(var inp of document.querySelectorAll(".filter_form .tag_check input")) {
        inp.addEventListener("change", update_rows_visibility);
    }

    document.getElementById("keys_quick_filter").addEventListener("input", update_rows_visibility);
}
