$("#image").on('click', func1);
let a = 1

$("img").click(func)

$('p').click(texte)

function func1()
{
    
    if (a/2 == 1) {
        $("#image").attr('src', 'quentin.png')
        a = 1
    }

    else {
        $("#image").attr('src', 'traumatized.webp')
        a += 1
    }
}

function func() {
    if ($(this).css('width') === '1000px') {
        $(this).toggleClass('papa')
    }
    if ($(this).is("#image")) {
        $(this).toggleClass('cou')
    }
}

function texte() {
    if ($(this).text() =='bonjoour') {
        $(this).replaceWith('<h1> coucou </h1>')
    }
    else {
        $(this).text('bonjoour')
    }
}