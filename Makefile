# FoodTracker (Forkcast) — test shortcut
#
# Override any variable at the call site, e.g.:
#   make test DEVICE="iPhone 16"

PROJECT     := FoodTracker.xcodeproj
SCHEME      := FoodTracker
DEVICE      := iPhone 17 Pro
DESTINATION := platform=iOS Simulator,name=$(DEVICE)

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
