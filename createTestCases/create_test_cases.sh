#!/bin/bash -e

urlencode() {
  local string="$1"
  local encoded_string=$(echo "$string" | tr -d '\n' | jq -sRr @uri)
  echo "$encoded_string"
}

# Example usage:
# ./create_test_cases.sh "advocate@example.com" "1" "12" "ABOCUT_C" "AGFS16S28" "true" "2023-10-16" "1" "1" "Junior" "Joe" "Bloggs" "2000-01-01" "2023-10-16" "6015685" "1" "1000" "MISTE"
# ./create_test_cases.sh "advocate@example.com" "34" "12" "POFBPPCOC_12.2" "8010101012" "true" "2025-06-09" "1" "1" "Leading junior" "Joe" "Bloggs" "2000-01-01" "2025-06-09" "6015685" "1" "1000" "BABAF"

API_KEY="10e76205-5fd3-49d9-895d-b9de5f415a6a" # PLEASE ADD YOUR API KEY
API_DOMAIN="http://localhost:3001"

# Create AGFS 16 Claim PARAMS
USER_EMAIL=$(urlencode "${1}") # advocate@example.com
echo -e "\n==== USER_EMAIL: $USER_EMAIL"
COURT_ID=$(urlencode "${2}") # c.COUR_COURT_CODE
echo -e "\n==== COURT_ID: $COURT_ID"
CASE_TYPE_ID=$(urlencode "${3}") # bs.SCENARIO AS BILL_SCENARIO
echo -e "\n==== CASE_TYPE_ID: $CASE_TYPE_ID"
OFFENCE_UNIQUE_CODE=$(urlencode "${4}") # oc.UNIQUE_CODE
echo -e "\n==== OFFENCE_UNIQUE_CODE: $OFFENCE_UNIQUE_CODE"
CASE_NUMBER=$(urlencode "${5}") # c.CASE_NO
echo -e "\n==== CASE_NUMBER: $CASE_NUMBER"
APPLY_VAT=$(urlencode "${6}") # b.VAT_INCLUDED
echo -e "\n==== APPLY_VAT: $APPLY_VAT"
DATE=$(urlencode "${7}") # c.TRIAL_DATE_START
echo -e "\n==== DATE: $DATE"
E_LENGTH=$(urlencode "${8}") # c.EST_TRIAL_LENGTH
echo -e "\n==== E_LENGTH: $E_LENGTH"
A_LENGTH=$(urlencode "${9}") # c.ACT_TRAIL_LENGTH
echo -e "\n==== A_LENGTH: $A_LENGTH"
ADVOCATE_TYPE=$(urlencode "${10}") # PSTY_PERSON_TYPE
echo -e "\n==== ADVOCATE_TYPE: $ADVOCATE_TYPE"

# Create Defendant PARAMS
FIRST=$(urlencode "${11}") # c.CLIENT_FORENAME
echo -e "\n==== FIRST: $FIRST"
LAST=$(urlencode "${12}") # c.CLIENT_SURNAME
echo -e "\n==== LAST: $LAST"
DOB=$(urlencode "${13}") # c.CLIENT_DOB
echo -e "\n==== DOB: $DOB"

# Create Rep Order PARAMS
REP_ORDER_DATE=$(urlencode "${14}") # REP_ORD_DATE
echo -e "\n==== REP_ORDER_DATE: $REP_ORDER_DATE"
MAAT_REF=$(urlencode "${15}") # cr.MAAT_REFERENCE
echo -e "\n==== MAAT_REF: $MAAT_REF"

# Create Fee PARAMS
QUANTITY=$(urlencode "${16}") # b.QUANTITY
echo -e "\n==== QUANTITY: $QUANTITY"
RATE=$(urlencode "${17}") # b.RATE
echo -e "\n==== RATE: $RATE"
FEE_UNIQUE_CODE=$(urlencode "${18}") # bt.BILL_TYPE, bst.BILL_SUB_TYPE pair
echo -e "\n==== FEE_UNIQUE_CODE: $FEE_UNIQUE_CODE"

# PARAMS GET FROM API
OFFENCE_ID="" # 1093, 1711
CLAIM_ID=""
DEFENDANT_ID=""

# FLOW START
echo -e "create_test_cases.sh started!"
declare -a RESPONSE

# GET Offence
echo -e "\n>>> Getting Offence..."
RESPONSE=$(curl -s --location --globoff "$API_DOMAIN/api/offences?rep_order_date=$REP_ORDER_DATE&unique_code=$OFFENCE_UNIQUE_CODE&api_key=$API_KEY")
echo -e "\nRESPONSE:$RESPONSE"
echo -e "\n>>> Offence found successfully."

# Parse OFFENCE_ID from response
OFFENCE_ID=$(jq -r '.[0].id' <<< "$RESPONSE")
echo -e "\n==== OFFENCE_ID: $OFFENCE_ID"
unset RESPONSE

# Create AGFS 16 Claim
echo -e "\n>>> Creating AGFS 16 Claim..."
RESPONSE=$(curl --location --globoff --request POST "$API_DOMAIN/api/external_users/claims/advocates/final?creator_email=$USER_EMAIL&court_id=$COURT_ID&case_type_id=$CASE_TYPE_ID&offence_id=$OFFENCE_ID&case_number=$CASE_NUMBER&apply_vat=$APPLY_VAT&first_day_of_trial=$DATE&estimated_length_of_trial=$E_LENGTH&trial_concluded_at=$DATE&actual_trial_length=$A_LENGTH&user_email=$USER_EMAIL&advocate_category=$ADVOCATE_TYPE&api_key=$API_KEY")

echo -e "\nRESPONSE:$RESPONSE"
echo -e "\n>>> AGFS 16 Claim created successfully."

# Parse CLAIM_ID from response
CLAIM_ID=$(jq -r '.id' <<< "$RESPONSE")
echo -e "\n==== CLAIM_ID: $CLAIM_ID"
unset RESPONSE

# Create Defendant
echo -e "\n>>> Creating Defendant..."
RESPONSE=$(curl -s --location --globoff --request POST "$API_DOMAIN/api/external_users/defendants?claim_id=$CLAIM_ID&first_name=$FIRST&last_name=$LAST&date_of_birth=$DOB&api_key=$API_KEY")
echo -e "\nRESPONSE:$RESPONSE"
echo -e "\n>>> Defendant created successfully."

# Parse DEFENDANT_ID from response
DEFENDANT_ID=$(jq -r '.id' <<< "$RESPONSE")
echo -e "\n==== DEFENDANT_ID: $DEFENDANT_ID"
unset RESPONSE

# Create Rep Order
echo -e "\n>>> Creating Representation Order..."
RESPONSE=$(curl -s --location --globoff --request POST "$API_DOMAIN/api/external_users/representation_orders?defendant_id=$DEFENDANT_ID&maat_reference=$MAAT_REF&representation_order_date=$REP_ORDER_DATE&api_key=$API_KEY")
echo -e "\nRESPONSE:$RESPONSE"
echo -e "\n>>> Representation Order created successfully."

unset RESPONSE

# Create Fee
echo -e "\n>>> Creating Fee..."
RESPONSE=$(curl -s --location --globoff --request POST "$API_DOMAIN/api/external_users/fees/?claim_id=$CLAIM_ID&fee_type_unique_code=$FEE_UNIQUE_CODE&amount="5000"&api_key=$API_KEY")
echo -e "\nRESPONSE:$RESPONSE"
echo -e "\n>>> Fee created successfully."

unset RESPONSE

echo -e "\ncreate_test_cases.sh finished!"