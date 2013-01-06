$ ->
	generatePath = (text) ->
		text.toLowerCase().replace(/\s+/g, "-").replace(/'":\.\/&^\*/g, "")
	
	path = $("input#project_path")
	
	$("input#project_name").blur ->
		if path.val() == ""
			path.val("/home/gitlab_ci/" + generatePath($(this).val()))