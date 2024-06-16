$(window).on('load', function () {
    $('img').css('display', 'none');
    imageSrc = $('img').attr('src');
    imageWidth = $('img').innerWidth();
    imageHeight = $('img').innerHeight();

    decoupe = imageWidth / 5;

    $('section').css('width', imageWidth);
    $('div').css('width', decoupe);
    $('div').css('height', imageHeight);


    $('div').css({ 'background-image': 'url("' + imageSrc + '")' });


    compteur = 0;
    backgroundPositionNow = decoupe;

    $('div').each(function(){
        if (compteur < 5) {
            $(this).slideUp()
            $(this).css("background-position", backgroundPositionNow - decoupe);
            backgroundPositionNow -= decoupe;
        }
        compteur++;
    })

})
