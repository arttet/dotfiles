def targets:
  ["bash", "zsh", "nu", "tmux"];

def round3:
  (. * 1000 | round) / 1000;

def round2:
  (. * 100 | round) / 100;

def measurements($results):
  reduce targets[] as $target ({};
    ($results | map(select(.command == ($target + ".raw")) | .median) | first) as $raw
    | ($results | map(select(.command == ($target + ".configured")) | .median) | first) as $configured
    | if ($raw | type) != "number" or ($configured | type) != "number" or $raw <= 0 or $configured <= 0 then
        error("missing or invalid benchmark results for " + $target)
      else
        .[$target] = {raw: $raw, configured: $configured, ratio: ($configured / $raw)}
      end
  );

def validate_baseline($baseline):
  if ($baseline.schemaVersion != 1) then error("unsupported baseline schema")
  elif ($baseline.platform != "linux") then error("baseline platform must be linux")
  elif (($baseline.threshold | type) != "number") or $baseline.threshold < 0 then error("invalid baseline threshold")
  elif (targets | all($baseline.metrics[.] | type == "number" and . > 0) | not) then error("missing or invalid baseline metrics")
  else $baseline
  end;

def measurement_table($measurements):
  [
    "| Target | Raw median | Configured median | Ratio |",
    "| --- | ---: | ---: | ---: |",
    (targets[] as $target
      | $measurements[$target]
      | "| \($target) | \(.raw * 1000 | round2) ms | \(.configured * 1000 | round2) ms | \(.ratio | round3)x |")
  ] | join("\n");

def comparison_table($rows):
  [
    "| Target | Baseline ratio | Current ratio | Change | Result |",
    "| --- | ---: | ---: | ---: | --- |",
    ($rows[] |
      "| \(.target) | \(.baseline | round3)x | \(.current | round3)x | \(.change * 100 | round2)% | \(if .regression then "Regression" else "Pass" end) |")
  ] | join("\n");

($benchmark[0].results | measurements(.)) as $measurements
| ($measurements | with_entries(.value = .value.ratio)) as $current
| {
    schemaVersion: 1,
    platform: "linux",
    threshold: 0.05,
    metrics: $current
  } as $candidate
| if $mode == "update" then
    {baseline: $candidate}
  elif $mode == "check" then
    (validate_baseline($baseline[0])) as $base
    | (targets | all($base.metrics[.] == 1)) as $bootstrap
    | [
        targets[] as $target
        | (($current[$target] - $base.metrics[$target]) / $base.metrics[$target]) as $change
        | {
            target: $target,
            baseline: $base.metrics[$target],
            current: $current[$target],
            change: $change,
            regression: ($change > ($base.threshold + 1e-12))
          }
      ] as $rows
    | ($rows | all(.regression == false)) as $passed
    | {
        passed: (if $bootstrap then false else $passed end),
        report: (
          "## Performance report\n\n"
          + if $bootstrap then
              "**Failed:** the committed baseline is not initialized.\n\n"
              + "### Current measurements\n\n"
              + measurement_table($measurements)
              + "\n\n### Baseline candidate\n\n"
              + "Commit the following values through `just bench update` on Linux:\n\n"
              + "```json\n"
              + ($candidate | tojson)
              + "\n```\n\n"
              + $tables
            else
              (if $passed then "**Passed**" else "**Failed**" end)
              + " with a regression threshold of \($base.threshold * 100)%.\n\n"
              + $tables
              + "### Regression comparison\n\n"
              + comparison_table($rows)
              + "\n"
            end
        )
      }
  else
    error("unsupported mode: " + $mode)
  end
