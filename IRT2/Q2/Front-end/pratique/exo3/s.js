$(function() {
    $("#mot2Passe").on('input', function() {
        let listeBlanche = ["123456", "12345", "1234", "abc123", "abc",
        "pwd", "password", "mypassword", "dragon", "monkey", "shadow",
        "master", "superman", "spiderman", "batman", "god", "sex", "boobs",
        "azerty", "qwerty", "iloveyou", "computer", "welcome", "matrix",
        "secret", "login"];
        let mdp = $(this).val();
        let longMdp = mdp.length;
        let $meter = $("#meter");

        $meter.attr("value", longMdp);
        if (listeBlanche.includes(mdp)){
            $meter.attr("value", "1");
        }
    });

    $("#showMot2Passe").on('input', function() {
        let $baliseMdp = $("#mot2Passe");
        if ($(this).is(":checked")){
            $baliseMdp.attr("type", "text");
        } else {
            $baliseMdp.attr("type", "password");
        }
    });
});