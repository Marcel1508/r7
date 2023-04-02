/**
* Created by ffeix on 07/21/2021.
*
*/
({
    doInit: function(component, event, helper) {
        console.group('%c gbJsScript', 'background: #76b72a; color: #ffffff');
        var gbJsScript = document.createElement("script");
        gbJsScript.src =
            "https://cdn.goldenbees.fr/proxy?url=http%3A%2F%2Fstatic.goldenbees.fr%2Fcdn%2Fjs%2Fgtag%2Fgoldentag-min.js&attachment=0";
        document.head.appendChild(gbJsScript);
        gbJsScript.addEventListener("load", function() {
            var gbTag = GbTagBuilder.build("idwbma");
            gbTag.fire();
        })
        console.groupEnd();
    }
})