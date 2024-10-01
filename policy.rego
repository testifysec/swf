policy rego

// lint commandrun cmd validation
package commandrun.cmd

deny[msg] {
	input.cmd != ["/bin/sh", "-c", "hadolint -f sarif Dockerfile > hadolint.sarif"]
	msg := "unexpected cmd"
}

// all github jwt validation
package github.attributes

import rego.v1

deny[msg] if {
	input.jwt.claims.iss != "https://token.actions.githubusercontent.com"
	msg := "unexpected issuer"
}

deny[msg] if {
	input.projecturl != "https://github.com/testifysec/swf"
	msg := "unexpected projecturl"
}

deny[msg] if {
	not startswith(input.jwt.claims.workflow_ref, "testifysec/swf/.github/workflows/pipeline.yml")
	msg := "unexpected workflow_ref"
}

// webhook attestor PR approval
package pr_review

deny[msg] {
	input.event != "pull_request_review"
	msg := "not a pr review"
}

deny[msg] {
	input.payload.action != "submitted"
	msg := "not a submitted pr"
}

deny[msg] {
	input.payload.review.state != "approved"
	msg := "not an approved pr"
}
