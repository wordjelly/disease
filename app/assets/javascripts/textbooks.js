_.templateSettings = {
    interpolate: /\{\{\=(.+?)\}\}/g,
    evaluate: /\{\{(.+?)\}\}/g
};

_.templateSettings.variable = 'search_result'; 

var template;

var render_search_result = function(search_result){	
	if(_.isUndefined(template)){

		var template = _.template($('#search_result_template').html());
	}
	$('#search_results').append(template(search_result));
}
$(document).on('submit','#search_form',function(event){
	event.preventDefault();
	console.log($("#search").val());
	$.ajax({
	  url: "/textbooks/search",
	  dataType: "json",
	  type: "GET",
	  data:{query: $("#search").val()
	    }, 
	  beforeSend : function(xhr){
	  	$("#progress_bar").show();
	  },
	  success: function(response){
	   	$('#search_results').html("");
	    _.each(response['results'],function(search_result,index,list){
	    	render_search_result(search_result);
	    });
	    $("#progress_bar").hide();
	  }
	});
	
});