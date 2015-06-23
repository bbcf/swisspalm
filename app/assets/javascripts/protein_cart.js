function upd_protein_cart(url){
 $.ajax({
                url: url,
                type: "get",
                dataType: "html",
                data: {},
                success: function(returnData){
                   $('#protein_cart').html(returnData);
                },
                error: function(e){
                  alert(e);
                   }
            });
}


