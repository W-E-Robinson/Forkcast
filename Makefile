# FoodTracker (Forkcast) — test shortcut
#
# Override any variable at the call site, e.g.:
#   make test DEVICE="iPhone 16"
#   make test OS=26.5

PROJECT     := FoodTracker.xcodeproj
SCHEME      := FoodTracker
DEVICE      := iPhone 17
# A device name alone is ambiguous when several installed runtimes provide it,
# so the runtime is always part of the destination. `latest` keeps this from
# going stale, which means DEVICE has to be a model the newest runtime ships.
OS          := latest
DESTINATION := platform=iOS Simulator,name=$(DEVICE),OS=$(OS)

# Trim xcodebuild's firehose to just pass/fail lines. Pipe through xcbeautify
# instead if you have it: `make test | xcbeautify`.
FILTER := grep -iE "Test Suite|passed|failed|error:|Executed|\*\* TEST" \
          | grep -viE "note:|generated-files|-headers"

.DEFAULT_GOAL := test

.PHONY: test

## test: run the full test suite
test:
	set -o pipefail; xcodebuild test \
	  -project $(PROJECT) -scheme $(SCHEME) \
	  -destination '$(DESTINATION)' | $(FILTER)
