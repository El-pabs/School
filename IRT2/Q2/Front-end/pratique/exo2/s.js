function majTotal() {
    let valeur = $('#quantite').val()
    if (valeur < 0){
        $('#quantite').val(0)
    }
    if (valeur >= 2) {
        $('#art').text('articles')
    }
    else {
        $('#art').text('article')
    }

    $('#total').text(valeur*12.50).append('€')
}