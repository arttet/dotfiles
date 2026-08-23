# The VEX document is the only sanctioned way to silence a scanner in this repository, which makes it
# the one place where an unexplained entry would do real damage. These rules keep every suppression
# attributable: who said it, when, about what, and on what grounds.
package vex

import rego.v1

statuses := {"not_affected", "affected", "fixed", "under_investigation"}

# https://openvex.dev/ns — the justification vocabulary is closed, so a typo here would silently
# weaken the document rather than fail.
justifications := {
	"component_not_present",
	"vulnerable_code_not_present",
	"vulnerable_code_not_in_execute_path",
	"vulnerable_code_cannot_be_controlled_by_adversary",
	"inline_mitigations_already_exist",
}

required_fields := ["@context", "@id", "author", "timestamp", "version"]

deny contains msg if {
	some field in required_fields
	not input[field]
	msg := sprintf("VEX document is missing the required field %q", [field])
}

deny contains msg if {
	not startswith(input["@context"], "https://openvex.dev/ns")
	msg := sprintf("VEX document declares the unexpected context %q", [input["@context"]])
}

deny contains msg if {
	some index, statement in input.statements
	not statement.vulnerability.name
	msg := sprintf("statement %d does not name a vulnerability", [index])
}

deny contains msg if {
	some index, statement in input.statements
	count(object.get(statement, "products", [])) == 0
	msg := sprintf("statement %d lists no products", [index])
}

deny contains msg if {
	some index, statement in input.statements
	not statement.status in statuses
	msg := sprintf("statement %d has the invalid status %q", [index, statement.status])
}

deny contains msg if {
	some index, statement in input.statements
	statement.status == "not_affected"
	not statement.justification
	msg := sprintf(
		"statement %d suppresses %q without a justification",
		[index, statement.vulnerability.name],
	)
}

deny contains msg if {
	some index, statement in input.statements
	statement.status == "not_affected"
	not statement.justification in justifications
	msg := sprintf(
		"statement %d uses the justification %q, which is not an OpenVEX one",
		[index, statement.justification],
	)
}

deny contains msg if {
	some index, statement in input.statements
	statement.status == "affected"
	not statement.action_statement
	msg := sprintf(
		"statement %d marks %q affected without an action statement",
		[index, statement.vulnerability.name],
	)
}
