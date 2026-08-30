# The manifest is the only thing tying released bytes back to a commit, so its shape is enforced
# rather than trusted. A field that is silently absent or malformed would make every downstream
# check -- checksum verification, provenance, the consumer's own diff -- quietly weaker.
#
# This runs from `artifact:scan`, not from `security:conftest`: the manifest does not exist until the
# release has been built.
package manifest

import rego.v1

sets := {"dotfiles", "wallpapers"}

required_artifacts := {"dotfiles": {"dotfiles.tar.gz", "sbom.spdx.json", "vex.openvex.json", "licenses.json"}}

deny contains msg if {
	input.schemaVersion != 1
	msg := sprintf("schemaVersion is %v, expected 1", [input.schemaVersion])
}

deny contains msg if {
	not input.set in sets
	msg := sprintf("set %q is not one of %v", [input.set, sets])
}

# --- Source identity ---------------------------------------------------------

deny contains msg if {
	some field in ["commit", "tree"]
	value := object.get(input.source, field, "")
	not regex.match(`^[0-9a-f]{40}$`, value)
	msg := sprintf("source.%s is %q, which is not a 40-character hex digest", [field, value])
}

deny contains msg if {
	not input.source.repository
	msg := "source.repository is missing"
}

# --- Build inputs ------------------------------------------------------------

# Same commit plus a different vendir lock file yields different bytes, so both hashes are part of
# the release identity and neither may be absent.
deny contains msg if {
	some kind in ["config", "lock"]
	entry := object.get(input.build.vendir, kind, {})
	not regex.match(`^[0-9a-f]{64}$`, object.get(entry, "sha256", ""))
	msg := sprintf("build.vendir.%s.sha256 is not a 64-character hex digest", [kind])
}

deny contains msg if {
	some kind in ["config", "lock"]
	entry := object.get(input.build.vendir, kind, {})
	object.get(entry, "file", "") == ""
	msg := sprintf("build.vendir.%s.file is missing", [kind])
}

deny contains msg if {
	not is_number(input.build.fileCount)
	msg := "build.fileCount is missing or not a number"
}

deny contains msg if {
	is_number(input.build.fileCount)
	input.build.fileCount <= 0
	msg := "build.fileCount is zero, so the archive would be empty"
}

# --- Artifacts ---------------------------------------------------------------

deny contains msg if {
	count(input.artifacts) == 0
	msg := "artifacts is empty"
}

deny contains msg if {
	some artifact in input.artifacts
	not regex.match(`^[0-9a-f]{64}$`, object.get(artifact, "sha256", ""))
	msg := sprintf("artifact %q has no valid SHA-256", [object.get(artifact, "name", "<unnamed>")])
}

deny contains msg if {
	names := [name | some artifact in input.artifacts; name := artifact.name]
	count(names) != count({name | some name in names})
	msg := "artifacts contains duplicate names"
}

deny contains msg if {
	required := required_artifacts[input.set]
	present := {name | some artifact in input.artifacts; name := artifact.name}
	some name in required
	not name in present
	msg := sprintf("artifact %q is missing from the %q set", [name, input.set])
}
