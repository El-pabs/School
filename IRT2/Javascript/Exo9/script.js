$('#burger').on("click", function(){
    now = $('#navTop').css('display')
    if(now == 'flex'){
        $('#navTop').css('display', 'none');
    }

    else{
        $('#navTop').css('display', 'flex');
    }
})