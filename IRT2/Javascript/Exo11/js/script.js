

($('a').mouseover(function(){

    //$('#bubulle').css('display', 'block');
    $('#bubulle').css('left', $(this).position().left);
    $('#bubulle').css('top', $(this).position().top);
    $('#bubulle').css('width', $(this).innerWidth());

}));

//$('#bubulle').css('display', 'none');