function add_question_marks(){


$("table").each(function(){
  var curTable = $(this);
   if (curTable.attr('id')){
     curTable.find("th").each(function(event){
      var curHeader=$(this);
      html = curHeader.html();
      if (html!= '' && html.slice(-5) != '?</a>'){
//	alert(html.slice(-5));
       link = document.createElement("a");
       link.href = '#';
       link.zindex='100000';
       link.className='question_mark';
       link.name="header:" + curHeader.html();
       link.innerHTML = '?';
       curHeader.append(link);
      }
     });
   }
});

$('.question_mark').each(function(){
 var curlink = $(this);
 curlink.click(function(event){
  event.preventDefault();
  var p = "table_id=" + curlink.parent().parent().parent().parent().attr('id') + "&column_name=" + curlink.attr('name')
  $.ajax({
                url: '/table_header_captions/get?' + p,
                type: "get",
                dataType: "html",
                data: {},
                beforeSend: function( xhr ) {
                 $('#loading').toggleClass('hidden');
                },
                success: function(returnData){
                returnData=returnData.trim(); 
		if (returnData == ''){
                 returnData='No definition available.';
                }
                 var o = $('#caption_content');                 
                 o.html(returnData);		
                 $('#loading').toggleClass('hidden');
		 $('#caption').removeClass('hidden');
                                 
                },
                error: function(e){
                 alert(e);
                }
  });
  event.stopPropagation();
 });
});

}

