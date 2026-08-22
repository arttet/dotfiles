# Conventions this repository relies on but that no linter enforces.
#
# zizmor covers the generic GitHub Actions attack surface; these rules cover the local decisions:
# every job is time-boxed, network-restricted, and — where a workflow defines a `guard` job — anchored
# to the fork trust model.
package workflows

import rego.v1

harden_runner := "step-security/harden-runner"

# This policy is pointed at both workflows and composite actions. Pinning and checkout hygiene apply
# to every step either can run; jobs, permissions and the trust model exist only in workflows.
is_workflow if input.jobs

steps contains {"owner": name, "step": step} if {
	some name, job in input.jobs
	some step in job.steps
}

steps contains {"owner": "runs", "step": step} if {
	some step in input.runs.steps
}

# --- Action pinning ---------------------------------------------------------

deny contains msg if {
	some entry in steps
	entry.step.uses
	not pinned_to_sha(entry.step.uses)
	msg := sprintf(
		"%s uses %q, which is not pinned to a full commit SHA",
		[entry.owner, entry.step.uses],
	)
}

pinned_to_sha(uses) if {
	parts := split(uses, "@")
	count(parts) == 2
	regex.match(`^[0-9a-f]{40}$`, parts[1])
}

# Local composite actions (`./.github/actions/...`) carry no ref and are part of this repository.
pinned_to_sha(uses) if startswith(uses, "./")

# --- Time boxing ------------------------------------------------------------

deny contains msg if {
	some name, job in input.jobs
	not job["timeout-minutes"]
	msg := sprintf("job %q has no timeout-minutes", [name])
}

# --- Egress control ---------------------------------------------------------

# Only jobs that pull in an action reach the network in a way worth restricting; a job whose steps are
# all `run:` (the guard job, for one) has nothing to harden.
deny contains msg if {
	some name, job in input.jobs
	uses_any_action(job)
	not hardens_first(job)
	msg := sprintf("job %q must start with %s using `egress-policy: block`", [name, harden_runner])
}

uses_any_action(job) if {
	some step in job.steps
	step.uses
}

hardens_first(job) if {
	startswith(job.steps[0].uses, harden_runner)
	job.steps[0].with["egress-policy"] == "block"
}

# --- Permissions ------------------------------------------------------------

deny contains msg if {
	is_workflow
	not input.permissions
	msg := "workflow does not declare top-level `permissions`"
}

deny contains msg if {
	some name, job in input.jobs
	job.permissions == "write-all"
	msg := sprintf("job %q requests write-all permissions", [name])
}

# --- Credential hygiene -----------------------------------------------------

deny contains msg if {
	some entry in steps
	startswith(entry.step.uses, "actions/checkout@")
	not credentials_dropped(entry.step)
	msg := sprintf("%s checks out without `persist-credentials: false`", [entry.owner])
}

# Negated as a helper rather than compared inline: a checkout step with no `with:` block at all leaves
# the comparison undefined, which would quietly pass the very case that matters most.
credentials_dropped(step) if step.with["persist-credentials"] == false

# --- Fork trust model -------------------------------------------------------

# YAML 1.1 reads the bare key `on` as a boolean, so the trigger block lands under "true" once parsed.
# Reading `input.on` here would look correct and never match anything.
triggers := object.get(input, "true", {})

# `pull_request_target` runs workflow code from the base branch with write access and secrets while
# checking out the fork's tree. Nothing here needs it, and it is the usual way that guarantee is lost.
deny contains msg if {
	some trigger, _ in triggers
	trigger == "pull_request_target"
	msg := "`pull_request_target` is not allowed; use `pull_request`"
}

guarded_workflow if input.jobs.guard

deny contains msg if {
	guarded_workflow
	some name, job in input.jobs
	name != "guard"
	not depends_on_guard(job)
	msg := sprintf("job %q does not list `guard` in needs, so it would still run for a fork", [name])
}

depends_on_guard(job) if job.needs == "guard"

depends_on_guard(job) if "guard" in job.needs

# A job that touches a real secret or holds a write permission has to say, in its own `if:` or in the
# `if:` of the steps that use it, that the run is trusted. The check is textual on purpose: it is the
# only formulation that keeps holding when a new job is added.
deny contains msg if {
	guarded_workflow
	some name, job in input.jobs
	name != "guard"
	privileged(job)
	not references_trust(job)
	msg := sprintf(
		"job %q is privileged but never references `needs.guard.outputs.trusted`",
		[name],
	)
}

privileged(job) if {
	body := json.marshal(job)
	contains(replace(body, "secrets.GITHUB_TOKEN", ""), "secrets.")
}

privileged(job) if job.permissions[_] == "write"

references_trust(job) if contains(json.marshal(job), "needs.guard.outputs.trusted")
