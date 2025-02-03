$(window).scroll(function(){
    position = $(window).scrollTop();
    positionTop = position*0.5 + "px";
    $('html').css("background-position",'0 '+ positionTop );
});