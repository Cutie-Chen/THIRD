
$(function(){
    // index();
    $(".index_nav ul li").each(function(index){
        $(this).click(function(){
            $(this).addClass("nav_active").siblings().removeClass("nav_active");
            $(".index_tabs .inner").eq(index).fadeIn().siblings("div").stop().hide();
            // console.log(index);
            if(index==0){//国内疫情
                getDate1();
                calendarPic();
            }else if(index==1){//国内舆情
                tfidfbar();
                yuqingpie();
                word_cloud();
                lines();
                radar();
            }
        })
    });
    $(".tabs ul li").each(function(index){
       $(this).click(function(){
           $(".tabs ul li div .div").removeClass("tabs_active");
           $(this).find("div .div").addClass("tabs_active");
           $(".tabs_map>div").eq(index).fadeIn().siblings("div").stop().hide();
       })
   });
    $(".middle_top_bot ul li").each(function(){
        $(this).click(function(){
            $(".middle_top_bot ul li").removeClass("middle_top_bot_active");
            $(this).addClass("middle_top_bot_active");
        })
    });

});



