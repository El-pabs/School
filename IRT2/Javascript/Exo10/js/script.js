$('#burger').on("click", function () {
    now = $('#navSide').css('display')
    if (now == 'flex') {
        $('#navSide').css('display', 'none');
    }

    else {
        $('#navSide').css('display', 'flex');
    }
})

$('img').on("click", function () {
    now = $('#lightbox').css('display');
    src = $(this).attr('src');
    if (now == 'flex') {
        $('#lightbox').css('display', 'none');
    }

    else {
        $('#lightbox').css('display', 'flex');
        $('#big').attr('src', src);
    }
})

$(document).on("keyup", function (evenement) {
    if (evenement.keyCode == 27) {
        $('#lightbox').css('display', 'none');
    }
})