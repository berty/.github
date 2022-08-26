CONFIG_TEAMS := $(shell cat config.json | jq -r '.teams[]')
TEAMS ?= $(CONFIG_TEAMS)

gen: teams-json authorized_keys
.PHONY: gen

teams-json:
	@for team in $(TEAMS); do (set -e; \
		mkdir -p by-team/$$team; \
		set -x; \
		gh api /orgs/berty/teams/$$team/members | jq '{members: [.[].login]}' > by-team/$$team/team.json; \
	); done
.PHONY: teams-json

authorized_keys:
	for team in $(TEAMS); do (set -e; \
		cd by-team/$$team; \
		echo "# Generated. Do not edit." > authorized_keys; \
		echo >> authorized_keys; \
		for member in `cat team.json | jq -r .members[]`; do \
			echo "## https://github.com/$$member.keys" >> authorized_keys; \
			(set -xe; curl -s https://github.com/$$member.keys >> authorized_keys); \
			echo >> authorized_keys; \
		done; \
	); done
.PHONY: authorized_keys
