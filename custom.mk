scaffold: required
	@[ -d "workspaces/${env}/${region}" ]           		  || mkdir -p workspaces/${env}/${region}
	@[ -f "workspaces/${env}/${region}/auto.tf" ]   		  || ( cd workspaces/${env}/${region}; ln -s ${BACK}/base/auto.tf . )
	@[ -f "workspaces/${env}/${region}/main.tf" ]   		  || ( touch ./workspaces/${env}/${region}/main.tf )
	@[ -d "workspaces/${env}/${region}/vars.tf" ]   		  || ( cp ./base/vars.tf ./workspaces/${env}/${region} ) 
	@[ -d "workspaces/${env}/${region}/resources" ] 		  || ( mkdir -p workspaces/${env}/${region}/resources; echo "{}" > workspaces/${env}/${region}/resources/main.yaml; ) 
	@[ -d "workspaces/${env}/${region}/resources/policies" ]  || ( mkdir -p workspaces/${env}/${region}/resources/policies; touch workspaces/${env}/${region}/resources/policies/.gitkeep; ) 
	@make config
