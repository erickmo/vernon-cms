APP_NAME=app_admin

.PHONY: get run build-web test analyze gen gen-watch clean upgrade

get:
	flutter pub get

run:
	flutter run -d chrome --web-port=3001

run-dev:
	flutter run -d chrome --web-port=3001 --dart-define=BASE_URL=http://localhost:8080

build-web:
	flutter build web --release --dart-define=BASE_URL=https://api.yourdomain.com

test:
	flutter test

test-coverage:
	flutter test --coverage
	genhtml coverage/lcov.info -o coverage/html

analyze:
	flutter analyze

gen:
	flutter pub run build_runner build --delete-conflicting-outputs

gen-watch:
	flutter pub run build_runner watch --delete-conflicting-outputs

clean:
	flutter clean
	flutter pub get

upgrade:
	flutter pub upgrade
