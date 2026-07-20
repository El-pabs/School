$(window).on('load',function(){
    $('.apparition').css('opacity', 0);
    old = $(window).scrollTop();
})
$(window).scroll( function(){


    hauteur = $(window).scrollTop() + $(window).height()

    if ($(window).scrollTop() >= old + 50){
        $('.apparition').each(function(){
            if ($(this).offset().top < hauteur){
                $(this).css('opacity', 1);
                old = $(window).scrollTop();
            }
        })
        
    }
});
