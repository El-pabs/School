x = $("#num").html();
x = parseInt(x);
$("img").on("click", function () {

    if (x == $('#plateau img').length) {
        x = 1;
        $("#num").html(x);
    }
    else {
        x++;
        $("#num").html(x);
    }

    newHauteur = (x - 1) * -600;
    newHauteur = newHauteur + "px";
    $('#plateau').css('top', newHauteur);
})