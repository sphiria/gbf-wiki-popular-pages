#!/usr/bin/env bash
set -Euo pipefail

###############################################################################
USERAGENT="sphiria/gbf-wiki-popular-pages"

PAGE="PopularPages"
PAGETEXT="$1"

USERNAME="$WIKI_BOT_USERNAME"
USERPASS="$WIKI_BOT_PASSWORD"
WIKI="https://gbf.wiki/"
WIKIAPI="https://gbf.wiki/api.php"
###############################################################################


# 0. Prep temp. dir
###############################################################################
TEMP_DIR="$(mktemp -d)"
trap 'rm -rf -- "$TEMP_DIR"' EXIT
cookie_jar="${TEMP_DIR}/wikicj"


# 1. Login
###############################################################################
echo "1. Obtaining login token..."
CR=$(curl -S \
	--retry 2 \
	--retry-delay 5 \
	--cookie-jar $cookie_jar \
  --header "User-Agent: $USERAGENT" \
  --silent \
	--request "GET" "${WIKIAPI}?action=query&meta=tokens&type=login&format=json")

# echo "$CR" | jq .

echo "$CR" > ${TEMP_DIR}/login.json
TOKEN=$(jq --raw-output '.query.tokens.logintoken' ${TEMP_DIR}/login.json)

if [ "$TOKEN" == "null" ]; then
	echo "Getting a login token failed."
	exit
else
  echo "::add-mask::$TOKEN"
	echo "Login token is $TOKEN"
	echo && echo "-----" && echo
fi


# 2. Login...
###############################################################################
echo "2. Logging in..."
CR=$(curl -S \
	--cookie $cookie_jar \
	--cookie-jar $cookie_jar \
  --header "User-Agent: $USERAGENT" \
	--form "action=login" \
	--form "lgname=${USERNAME}" \
	--form "lgpassword=${USERPASS}" \
	--form "lgtoken=${TOKEN}" \
	--form "format=json" \
  --silent \
	--request "POST" "${WIKIAPI}")

# echo "$CR" | jq .

STATUS=$(echo $CR | jq '.login.result')
if [[ $STATUS == *"Success"* ]]; then
	echo "Successfully logged in as $USERNAME, STATUS is $STATUS."
	echo && echo "-----" && echo
else
	echo "Unable to login, is logintoken ${TOKEN} correct?"
	exit
fi


# 3. Login...
###############################################################################
echo "3. Fetching edit token..."

CR=$(curl -S \
	--cookie $cookie_jar \
	--cookie-jar $cookie_jar \
  --header "User-Agent: $USERAGENT" \
  --silent \
	--request "GET" "${WIKIAPI}?action=query&meta=tokens&format=json")

# echo "$CR" | jq .
echo "$CR" > ${TEMP_DIR}/edittoken.json
echo "-----" && echo && echo
EDITTOKEN=$(jq --raw-output '.query.tokens.csrftoken' ${TEMP_DIR}/edittoken.json)

# Remove carriage return!
if [[ $EDITTOKEN == *"+\\"* ]]; then
  echo "::add-mask::$EDITTOKEN"
	echo "Edit token is: $EDITTOKEN"
	echo && echo "-----" && echo
else
	echo "Edit token not set."
	exit
fi


# 4. Edit
###############################################################################
echo "4. Editing page..."
CR=$(curl -S \
	--cookie $cookie_jar \
	--cookie-jar $cookie_jar \
  --header "User-Agent: $USERAGENT" \
  --silent \
	--form "action=edit" \
	--form "format=json" \
	--form "title=${PAGE}" \
	--form "text=${PAGETEXT}" \
	--form "token=${EDITTOKEN}" \
	--request "POST" "${WIKIAPI}")

# echo "$CR" | jq .
echo && echo "-----" && echo
echo "Done!"