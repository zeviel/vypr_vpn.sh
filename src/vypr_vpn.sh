#!/bin/bash

api="https://api.goldenfrog.com"
validation_api="https://validation.api.goldenfrog.com"
product="VyprVPN"
platform="Android"
platform_version=9
version="4.5.2.113841"
user_agent="okhttp/3.14.7"

function get_self_info() {
	curl --request GET \
		--url "$validation_api/$product/connections/self" \
		--user-agent "$user_agent" \
		--header "content-type: application/json" \
		--header "x-gf-platform: $platform" \
		--header "x-gf-platform-version: $platform_version" \
		--header "x-gf-product: $product" \
		--header "x-gf-product-version: $version"
}

function register() {
	# 1 - communication_locale: (string): <communication_locale - default: ru-RU>
	# 2 - email: (string): <email>
	# 3 - name: (string): <name>
	# 4 - password: (string): <password>
	curl --request POST \
		--url "$api/platform-gf/api/actions/signup/create-principal" \
		--user-agent "$user_agent" \
		--header "content-type: application/json" \
		--header "x-gf-platform: $platform" \
		--header "x-gf-platform-version: $platform_version" \
		--header "x-gf-product: $product" \
		--header "x-gf-product-version: $version" \
		--data '{
			"communication_locale": "'${1:-ru-RU}'",
			"email": "'$2'",
			"name": "'$3'",
			"password": "'$4'",
			"username": "'$3'"
		}'
}

function get_id_token() {
	# 1 - email: (string): <email>
	# 2 - password: (string): <password>
	response=$(curl --request POST \
		--url "$api/platform-gf/oidc/token" \
		--user-agent "$user_agent" \
		--header "content-type: application/x-www-form-urlencoded" \
		--header "x-gf-platform: $platform" \
		--header "x-gf-platform-version: $platform_version" \
		--header "x-gf-product: $product" \
		--header "x-gf-product-version: $version" \
		--data "client_id=ph-mobile&client_secret=ph-mobile-secret&grant_type=password&username=$1&password=$2&scope=openid profile groups tenant")
	if [ -n $(jq -r ".id_token" <<< "$response") ]; then
		id_token=$(jq -r ".id_token" <<< "$response")
	fi
	echo $response
}

function get_offering_details() {
	# 1 - offering_id: (string): <offering_id>
	curl --request GET \
		--url "$api/platform-gf/api/product/offerings/$1/actions/get-details" \
		--user-agent "$user_agent" \
		--header "content-type: application/json" \
		--header "x-gf-platform: $platform" \
		--header "x-gf-platform-version: $platform_version" \
		--header "x-gf-product: $product" \
		--header "x-gf-product-version: $version"
}

function get_locations() {
	curl --request GET \
		--url "$api/$product/locations-unauthenticated" \
		--user-agent "$user_agent" \
		--header "content-type: application/json" \
		--header "x-gf-platform: $platform" \
		--header "x-gf-platform-version: $platform_version" \
		--header "x-gf-product: $product" \
		--header "x-gf-product-version: $version"
}
