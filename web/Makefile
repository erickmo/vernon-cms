APP_NAME=vernon_cms_ui

.PHONY: get build run clean test analyze gen

## Setup
get:
	flutter pub get

## Run (BASE_URL dikonfigurasi via .env, port 3000 untuk match CORS backend)
run:
	flutter run -d chrome --web-port=3000

## Build (copy .env yang sesuai sebelum build)
build-web:
	flutter build web --release

## Testing
test:
	flutter test

test-coverage:
	flutter test --coverage
	genhtml coverage/lcov.info -o coverage/html
	@echo "Coverage: coverage/html/index.html"

## Code Quality
analyze:
	flutter analyze

lint:
	dart fix --dry-run

fix:
	dart fix --apply

## Code Generation
gen:
	flutter pub run build_runner build --delete-conflicting-outputs

gen-watch:
	flutter pub run build_runner watch --delete-conflicting-outputs

## Utilities
clean:
	flutter clean
	flutter pub get

upgrade:
	flutter pub upgrade
