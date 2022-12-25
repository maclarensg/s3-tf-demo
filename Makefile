include setup.config

CMD=nerdctl
VERSION=${version}
IMAGE=hashicorp/terraform:${VERSION}
TEMPLATER=maclarensg/gotemplater
RENDER=${CMD} run --rm -it -v ${PWD}:/tf -w /tf ${TEMPLATER}
PROJECT =$(lastword $(subst /, ,$(PWD)))

# --- Variable depends on Tiering starts here ---#
ifeq ($(tier), 1)
	CONTAINER=${CMD} run --rm -it -e "AWS_PROFILE=${env}" -v ${HOME}/.aws:/root/.aws -v ${PWD}/.gitconfig:/root/.gitconfig -v ${PWD}:/tf -w /tf/workspaces/${env} --entrypoint "" ${IMAGE}
	BACK=../..
endif

ifeq ($(tier), 2)
	CONTAINER=${CMD} run --rm -it -e "AWS_PROFILE=${env}" -v ${HOME}/.aws:/root/.aws  -v ${PWD}/.gitconfig:/root/.gitconfig -v ${PWD}:/tf -w /tf/workspaces/${env}/${region} --entrypoint "" ${IMAGE}
	BACK=../../..
endif
ifeq ($(tier), 3)
	CONTAINER=${CMD} run --rm -it -e "AWS_PROFILE=${env}" -v ${HOME}/.aws:/root/.aws -v ${PWD}/.gitconfig:/root/.gitconfig -v ${PWD}:/tf -w /tf/workspaces/${env}/${region}/${group} --entrypoint "" ${IMAGE}
	BACK=../../../..
endif
# --- Variable depends on Tiering ends here ---#


# --- Standard Targets starts here ---#
test:
	@echo ${CMD}
	@echo ${VERSION}
	@echo ${IMAGE}
ifeq ($(tier), 1)
	@echo tier 1
endif
ifeq ($(tier), 2)
	@echo tier 2
endif
ifeq ($(tier), 3)
	@echo tier 3
endif

help:
	@echo "To create a new workspace"
	@echo "-------------------------"
	@echo "See setup.config to find out which Tier is configured"
	@echo "# Tier 1"
	@echo "make scaffold env=<env_name>"
	@echo "# Tier 2"
	@echo "make scaffold env=<env_name> region=<aws_region>"
	@echo "# Tier 3"
	@echo "make scaffold env=<env_name> region=<aws_region> group=<group_name>"
	@echo ""
	@echo "To enter shell mode of a workspace"
	@echo "----------------------------------"
	@echo "This is for advance terraform usage. For resources creation. please follow CI"
	@echo ""
	@echo "make shell env=<env_name> ..."
	
required:
	@[ "${env}" ] || ( echo "env is required."; exit 1 )
ifeq ($(tier), 2)
	@[ "${region}" ] || ( echo "region is required."; exit 1 )
endif
ifeq ($(tier), 3)
	@[ "${group}" ] || ( echo "group is required."; exit 1 )
endif

config: required
	@echo "Env: ${env}" > tmp/.config
	@echo "Tier: ${tier}" >> tmp/.config
	@echo "Project: ${PROJECT}" >> tmp/.config
	@echo "Domain: ${domain}" >> tmp/.config
ifeq ($(tier), 1)	
	@${RENDER} gotemplater -d /tf/tmp/.config -t /tf/base/provider.tf.gotmpl -o /tf/workspaces/${env}/provider.tf
endif
ifeq ($(tier), 2)
	@echo "AwsRegion: ${region}" >> tmp/.config	
	@${RENDER} gotemplater -d /tf/tmp/.config -t /tf/base/provider.tf.gotmpl -o /tf/workspaces/${env}/${region}/provider.tf
	@${RENDER} gotemplater -d /tf/tmp/.config -t /tf/base/terraform.auto.tfvars.gotmpl -o /tf/workspaces/${env}/${region}/terraform.auto.tfvars
endif
ifeq ($(tier), 3)
	@echo "AwsRegion: ${region}" >> tmp/.config	
	@echo "Group: ${group}" >> tmp/.config	
	@${RENDER} gotemplater -d /tf/tmp/.config -t /tf/base/provider.tf.gotmpl -o /tf/workspaces/${env}/${region}/${group}/provider.tf
	@${RENDER} gotemplater -d /tf/tmp/.config -t /tf/base/terraform.auto.tfvars.gotmpl -o /tf/workspaces/${env}/${region}/${group}/terraform.auto.tfvars
endif

scaffold: required
	-Wno-old-command
ifeq ($(tier), 1)
	@[ -d "workspaces/${env}" ]               || mkdir -p workspaces/${env}
	@[ -d "workspaces/${env}/local_modules" ] || (cd workspaces/${env}; ln -s ${BACK}/local_modules . )
	@[ -f "workspaces/${env}/auto.tf" ]   	  || ( cd workspaces/${env}; ln -s ${BACK}/base/auto.tf . )
	@[ -f "workspaces/${env}/main.tf" ]   	  || ( touch ./workspaces/${env}/main.tf )
	@[ -f "workspaces/${env}/vars.tf" ]   	  || ( cp ./base/vars.tf ./workspaces/${env}/ ) 
	@[ -d "workspaces/${env}/resources" ] 	  || ( mkdir -p workspaces/${env}/resources; echo "{}" > workspaces/${env}/resources/main.yaml; ) 
endif
ifeq ($(tier), 2)
	@[ -d "workspaces/${env}/${region}" ]               || mkdir -p workspaces/${env}/${region}
	@[ -d "workspaces/${env}/${region}/local_modules" ] || (cd workspaces/${env}/${region}; ln -s ${BACK}/local_modules . )
	@[ -f "workspaces/${env}/${region}/auto.tf" ]   	|| ( cd workspaces/${env}/${region}; ln -s ${BACK}/base/auto.tf . )
	@[ -f "workspaces/${env}/${region}/main.tf" ]   	|| ( touch ./workspaces/${env}/${region}/main.tf )
	@[ -f "workspaces/${env}/${region}/vars.tf" ]   	|| ( cp ./base/vars.tf ./workspaces/${env}/${region} ) 
	@[ -d "workspaces/${env}/${region}/resources" ] 	|| ( mkdir -p workspaces/${env}/${region}/resources; echo "{}" > workspaces/${env}/${region}/resources/main.yaml; ) 
endif
ifeq ($(tier), 3)
	@[ -d "workspaces/${env}/${region}/${group}" ]               || mkdir -p workspaces/${env}/${region}/${group}
	@[ -d "workspaces/${env}/${region}/${group}/local_modules" ] || (cd workspaces/${env}/${region}/${group}; ln -s ${BACK}/local_modules . )
	@[ -f "workspaces/${env}/${region}/${group}/auto.tf" ]   	 || ( cd workspaces/${env}/${region}/${group}; ln -s ${BACK}/base/auto.tf . )
	@[ -f "workspaces/${env}/${region}/${group}/main.tf" ]   	 || ( touch ./workspaces/${env}/${region}/${group}/main.tf )
	@[ -f "workspaces/${env}/${region}/${group}/vars.tf" ]   	 || ( cp ./base/vars.tf ./workspaces/${env}/${region}/${group} ) 
	@[ -d "workspaces/${env}/${region}/${group}/resources" ] 	 || ( mkdir -p workspaces/${env}/${region}/${group}/resources; echo "{}" > workspaces/${env}/${region}/${group}/resources/main.yaml; ) 
endif
	@make config

clean:
	@${CONTAINER} /bin/rm -rf .terraform .terraform.lock.hcl

unscaffold:
ifeq ($(tier), 1)
	@[ -d "workspaces/${env}" ] && rm -rf workspaces/${env}
endif
ifeq ($(tier), 2)
	@[ -d "workspaces/${env}/${region}" ] && rm -rf workspaces/${env}/${region}
endif
ifeq ($(tier), 3)
	@[ -d "workspaces/${env}/${region}/${group}" ] && rm -rf workspaces/${env}/${region}/${group}
endif


shell: 
	@${CONTAINER} /bin/sh

.PHONY: test help config scaffold clean unscaffold shell 
.SILENT: 

# --- Standard Targets end here ---#

include custom.mk
