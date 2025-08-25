.PHONY: tf-init tf-apply tf-plan validate

tf-init:
	cd infra/terraform/envs/dev && terraform init

tf-plan:
	cd infra/terraform/envs/dev && terraform plan -var="project_id=YOUR_PROJECT_ID"

tf-apply:
	cd infra/terraform/envs/dev && terraform apply -auto-approve -var="project_id=YOUR_PROJECT_ID"

validate:
	python ci/scripts/validate_avro.py && bash ci/scripts/validate_proto.sh && conftest test infra/terraform --policy policy/conftest
