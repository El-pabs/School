$(document).ready(function(){
    $('.letters').css('display','none');
    $('.letters').each(function(){
        var left = 100 + Math.random() * ($(window).innerWidth()-200);
        var top = 100 + Math.random() * ($(window).innerHeight()-200);
        $(this).css({'left':left, 'top':top})
    })
    $('.letters').fadeIn();

    $('.letters').on('click', function(){
        $('.letters').removeClass('choix');
        $(this).addClass('choix');
    })
    $('.cases').on('click',function(){
        var left = $(this).offset().left;
        var top = $(this).offset().top;
        $('.choix').css({'left':left, 'top':top})
    })
})



