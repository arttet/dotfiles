# mise is the single source of tool versions for both developers and CI, so a floating version here
# means the two stop matching silently. Container images get the same treatment one level down: a tag
# is a moving pointer, a digest is not.
package mise

import rego.v1

floating := {"latest", "*"}

range_prefixes := ["^", "~", ">", "<", "="]

deny contains msg if {
	some name, spec in input.tools
	version := version_of(spec)
	version in floating
	msg := sprintf("tool %q is pinned to %q instead of an exact version", [name, version])
}

deny contains msg if {
	some name, spec in input.tools
	version := version_of(spec)
	some prefix in range_prefixes
	startswith(version, prefix)
	msg := sprintf("tool %q uses the version range %q instead of an exact version", [name, version])
}

version_of(spec) := spec if is_string(spec)

version_of(spec) := spec.version if is_object(spec)

deny contains msg if {
	some name, value in input.vars
	endswith(name, "_image")
	not contains(value, "@sha256:")
	msg := sprintf("var %q references a container image without an `@sha256:` digest", [name])
}
