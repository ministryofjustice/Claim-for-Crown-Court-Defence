#!/bin/bash

API_KEY="" # PLEASE ADD YOUR API KEY
API_DOMAIN="http://localhost:3001"

# PARAMS GET FROM API
CLAIM_ID=""
FEE_ID=""
DEFENDANT=""

# INPUT PARAMS
ROLE="agfs_scheme_16"
CATEGORY="misc"
CODE="MISTE"
CASE_TYPE_ID="12"
OFFENCE_ID="1093"
CASE_NUMBER="AGFS16S28"
DATE="2023-10-16"
LENGTH="1"
ADVOCATE_TYPE="Junior"
FIRST="Joe"
LAST="Bloggs"
QUANTITY="1"
RATE="1000"
REP_ORDER_DATE="2023-10-16"

# CONST PARAMS
USER_EMAIL="advocate%40example.com"
COURT_ID="1"
APPLY_VAT="true"
DOB="2000-01-01"
MAAT_REF="6015685"

# RESPONSE ARRAY
declare -a RESPONSE

echo -e "create_test_cases.sh started!"

# GET Fee Type
echo -e "\n>>> Getting Fee Type..."
RESPONSE=$(curl -s --location --globoff "$API_DOMAIN/api/fee_types?role=$ROLE&category=$CATEGORY&unique_code=$CODE&api_key=$API_KEY")
echo -e "\nRESPONSE:$RESPONSE"
echo -e "\n>>> Fee Type found successfully."

# Parse FEE_ID from response
FEE_ID=$(jq -r '.[0].id' <<< "$RESPONSE")
echo -e "\n==== FEE_ID: $FEE_ID"
unset RESPONSE

# Create AGFS 16 Claim
echo -e "\n>>> Creating AGFS 16 Claim..."
RESPONSE=$(curl -s --location --globoff --request POST "$API_DOMAIN/api/external_users/claims/advocates/final?creator_email=$USER_EMAIL&court_id=$COURT_ID&case_type_id=$CASE_TYPE_ID&offence_id=$OFFENCE_ID&case_number=$CASE_NUMBER&apply_vat=$APPLY_VAT&first_day_of_trial=$DATE&estimated_length_of_trial=$LENGTH&trial_concluded_at=$DATE&actual_trial_length=$LENGTH&user_email=$USER_EMAIL&advocate_category=$ADVOCATE_TYPE&api_key=$API_KEY")
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

# Parse DEFENDANT from response
DEFENDANT=$(jq -r '.id' <<< "$RESPONSE")
echo -e "\n==== DEFENDANT: $DEFENDANT"
unset RESPONSE

# Create Rep Order
echo -e "\n>>> Creating Representation Order..."
RESPONSE=$(curl -s --location --globoff --request POST "$API_DOMAIN/api/external_users/representation_orders?defendant_id=$DEFENDANT&maat_reference=$MAAT_REF&representation_order_date=$REP_ORDER_DATE&api_key=$API_KEY")
echo -e "\nRESPONSE:$RESPONSE"
echo -e "\n>>> Representation Order created successfully."

unset RESPONSE

# Create Fee
echo -e "\n>>> Creating Fee..."
RESPONSE=$(curl -s --location --globoff --request POST "$API_DOMAIN/api/external_users/fees/?claim_id=$CLAIM_ID&fee_type_id=$FEE_ID&quantity=$QUANTITY&rate=$RATE&api_key=$API_KEY")
echo -e "\nRESPONSE:$RESPONSE"
echo -e "\n>>> Fee created successfully."

unset RESPONSE

echo -e "\ncreate_test_cases.sh finished!"