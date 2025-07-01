#!/bin/bash
LOG_FILE="${0}_$(date +%Y%m%d%H%M).log"
exec > "$LOG_FILE" 2>&1
urlencode() {
  local string="$1"
  if [ -z "$string" ] || [ "$string" = "null" ]; then
    echo ""
  else
    local encoded_string=$(echo "$string" | tr -d '\n' | jq -sRr @uri)
    echo "$encoded_string"
  fi
}

# Check if a file was provided as an argument
if [ $# -ne 1 ]; then
  echo "Usage: $0 <json_file>"
  exit 1
fi

# Check if the file exists and is a file
if [ ! -f "$1" ]; then
  echo "Error: $1 is not a file"
  exit 1
fi

echo "!=== ${0} started..."

API_KEY="10e76205-5fd3-49d9-895d-b9de5f415a6a" # ADD YOUR API KEY
API_DOMAIN="http://localhost:3001" # ADD YOUR API DOMAIN

# Use jq to parse the JSON data
DATA_FILE="$1"
LAST_CASE_ID="00000"
LAST_FEE_ID="00000"
LAST_DEFENDANT_ID="00000"
LAST_CLAIM_ID="00000"
IS_ALL_FEE_ADDED="FALSE"
IS_ALL_DEFNANT_ADDED="FALSE"

# Count the number of items in the second level
ITEM_COUNT=$(jq '.[] | length' "$DATA_FILE" | head -n 1)
echo -e "\n==== Number of items: $ITEM_COUNT"

for ((i=0; i<ITEM_COUNT; i++)); do
    echo -e "\n==== Start of item: $i"

    CLAIM_FLAG="TRUE"
    FEE_FLAG="TRUE"
    DEFENDANT_FLAG="TRUE"

    # Extract the values from the JSON file
    case_id=$(jq -r '.[] | .['$i'].case_id' "$DATA_FILE")
    fee_id=$(jq -r '.[] | .['$i'].fee_id' "$DATA_FILE")
    defendant_id=$(jq -r '.[] | .['$i'].defendant_id' "$DATA_FILE")
    court_id=$(jq -r '.[] | .['$i'].court_id' "$DATA_FILE")
    case_type_id=$(jq -r '.[] | .['$i'].case_type_id' "$DATA_FILE")
    offence_id=$(jq -r '.[] | .['$i'].offence_id' "$DATA_FILE")
    case_number=$(jq -r '.[] | .['$i'].case_number' "$DATA_FILE")
    apply_vat=$(jq -r '.[] | .['$i'].apply_vat' "$DATA_FILE")
    first_day_of_trial=$(jq -r '.[] | .['$i'].first_day_of_trial' "$DATA_FILE")
    trial_concluded_at=$(jq -r '.[] | .['$i'].trial_concluded_at' "$DATA_FILE")
    estimated_trial_length=$(jq -r '.[] | .['$i'].estimated_trial_length' "$DATA_FILE")
    actual_trial_length=$(jq -r '.[] | .['$i'].actual_trial_length' "$DATA_FILE")
    advocate_category=$(jq -r '.[] | .['$i'].advocate_category' "$DATA_FILE")
    trial_cracked_at_third=$(jq -r '.[] | .['$i'].trial_cracked_at_third' "$DATA_FILE")
    trial_cracked_at=$(jq -r '.[] | .['$i'].trial_cracked_at' "$DATA_FILE")
    trial_fixed_notice_at=$(jq -r '.[] | .['$i'].trial_fixed_notice_at' "$DATA_FILE")
    trial_fixed_at=$(jq -r '.[] | .['$i'].trial_fixed_at' "$DATA_FILE")
    first_name=$(jq -r '.[] | .['$i'].first_name' "$DATA_FILE")
    last_name=$(jq -r '.[] | .['$i'].last_name' "$DATA_FILE")
    date_of_birth=$(jq -r '.[] | .['$i'].date_of_birth' "$DATA_FILE")
    maat_reference=$(jq -r '.[] | .['$i'].maat_reference' "$DATA_FILE")
    representation_order_date=$(jq -r '.[] | .['$i'].representation_order_date' "$DATA_FILE")
    quantity=$(jq -r '.[] | .['$i'].quantity' "$DATA_FILE")
    rate=$(jq -r '.[] | .['$i'].rate' "$DATA_FILE")
    amount=$(jq -r '.[] | .['$i'].amount' "$DATA_FILE")
    fee_type_id=$(jq -r '.[] | .['$i'].fee_type_id' "$DATA_FILE")

    # Create Claim PARAMS
    USER_EMAIL="advocate@example.com"
    echo -e "=> USER_EMAIL: $USER_EMAIL"
    CASE_ID=$(urlencode "$case_id")
    echo -e "=> CASE_ID: $CASE_ID"
    FEE_ID=$(urlencode "$fee_id")
    echo -e "=> FEE_ID: $FEE_ID"
    DEFENDANT_ID=$(urlencode "$defendant_id")
    echo -e "=> DEFENDANT_ID: $DEFENDANT_ID"
    COURT_ID=$(urlencode "$court_id")
    echo -e "=> COURT_ID: $COURT_ID"
    CASE_TYPE_ID=$(urlencode "$case_type_id")
    echo -e "=> CASE_TYPE_ID: $CASE_TYPE_ID"
    OFFENCE_ID=$(urlencode "$offence_id")
    echo -e "=> OFFENCE_ID: $OFFENCE_ID"
    CASE_NUMBER=$(urlencode "$case_number")
    echo -e "=> CASE_NUMBER: $CASE_NUMBER"
    APPLY_VAT=$(urlencode "$apply_vat")
    echo -e "=> APPLY_VAT: $APPLY_VAT"
    FIRST_TRIAL_DATE=$(urlencode "$first_day_of_trial")
    echo -e "=> FIRST_TRIAL_DATE: $FIRST_TRIAL_DATE"
    TRIAL_CONCLUDED_DATE=$(urlencode "$trial_concluded_at")
    echo -e "=> TRIAL_CONCLUDED_DATE: $TRIAL_CONCLUDED_DATE"
    E_LENGTH=$(urlencode "$estimated_trial_length")
    echo -e "=> E_LENGTH: $E_LENGTH"
    A_LENGTH=$(urlencode "$actual_trial_length")
    echo -e "=> A_LENGTH: $A_LENGTH"
    ADVOCATE_TYPE=$(urlencode "$advocate_category")
    echo -e "=> ADVOCATE_TYPE: $ADVOCATE_TYPE"
    TRIAL_CRACKED_AT_THIRD=$(urlencode "$trial_cracked_at_third")
    echo -e "=> TRIAL_CRACKED_AT_THIRD: $TRIAL_CRACKED_AT_THIRD"
    TRIAL_CRACKED_AT=$(urlencode "$trial_cracked_at")
    echo -e "=> TRIAL_CRACKED_AT: $TRIAL_CRACKED_AT"
    TRIAL_FIXED_NOTICE_AT=$(urlencode "$trial_fixed_notice_at")
    echo -e "=> TRIAL_FIXED_NOTICE_AT: $TRIAL_FIXED_NOTICE_AT"
    TRIAL_FIXED_AT=$(urlencode "$trial_fixed_at")
    echo -e "=> TRIAL_FIXED_AT: $TRIAL_FIXED_AT"

    # Create Defendant PARAMS
    FIRST=$(urlencode "$first_name")
    echo -e "=> FIRST: $FIRST"
    LAST=$(urlencode "$last_name")
    echo -e "=> LAST: $LAST"
    DOB=$(urlencode "$date_of_birth")
    echo -e "=> DOB: $DOB"

    # Create Rep Order PARAMS
    REP_ORDER_DATE=$(urlencode "$representation_order_date")
    echo -e "=> REP_ORDER_DATE: $REP_ORDER_DATE"
    MAAT_REF=$(urlencode "$maat_reference")
    echo -e "=> MAAT_REF: $MAAT_REF"

    # Create Fee PARAMS
    QUANTITY=$(urlencode "$quantity")
    echo -e "=> QUANTITY: $QUANTITY"
    RATE=$(urlencode "$rate")
    echo -e "=> RATE: $RATE"
    AMOUNT=$(urlencode "$amount")
    echo -e "=> AMOUNT: $AMOUNT"
    FEE_TYPE_ID=$(urlencode "$fee_type_id")
    echo -e "=> FEE_TYPE_ID: $FEE_TYPE_ID"

    # PARAMS GET FROM API
    CLAIM_ID=""
    DEFENDANT_ID=""

    # FLOW START
    declare -a RESPONSE

    # FLAGS SET
    if [ "$CASE_ID" == "$LAST_CASE_ID" ]; then
        CLAIM_ID=$LAST_CLAIM_ID
        echo -e "Same Case ID as last item"
        CLAIM_FLAG="FALSE"
    else
        IS_ALL_FEE_ADDED="FALSE"
        IS_ALL_DEFNANT_ADDED="FALSE"
    fi 
    
    if [ "$CASE_ID" == "$LAST_CASE_ID" ] && [ "$FEE_ID" == "$LAST_FEE_ID" ]; then
        echo -e "Same Fee ID as last item"
        FEE_FLAG="FALSE"
        if [ "$IS_ALL_DEFNANT_ADDED" == "TRUE" ]; then
            DEFENDANT_FLAG="FALSE"    
        fi
    elif [ "$CASE_ID" == "$LAST_CASE_ID" ] && [ "$FEE_ID" != "$LAST_FEE_ID" ]; then
        echo -e "All Defendant ID are being added"
        DEFENDANT_FLAG="FALSE"
        IS_ALL_DEFNANT_ADDED="TRUE"
    fi

    # Create Claim
    if [ "$CLAIM_FLAG" == "TRUE" ]; then
        echo -e "\n>>> Creating Claim..."

        QUERY_PARAMS="creator_email=$USER_EMAIL&court_id=$COURT_ID&case_type_id=$CASE_TYPE_ID&offence_id=$OFFENCE_ID&case_number=$CASE_NUMBER&apply_vat=$APPLY_VAT&estimated_length_of_trial=$E_LENGTH&actual_trial_length=$A_LENGTH&user_email=$USER_EMAIL&advocate_category=$ADVOCATE_TYPE&api_key=$API_KEY"

        if [ -n "$FIRST_TRIAL_DATE" ]; then
            echo -e "First trial date: $FIRST_TRIAL_DATE"
            QUERY_PARAMS+="&first_day_of_trial=$FIRST_TRIAL_DATE"
        fi

        if [ -n "$TRIAL_CONCLUDED_DATE" ]; then
            echo -e "Trial concluded date: $TRIAL_CONCLUDED_DATE"
            QUERY_PARAMS+="&trial_concluded_at=$TRIAL_CONCLUDED_DATE"
        fi

        if [ -n "$TRIAL_CRACKED_AT_THIRD" ]; then
            echo -e "Trial cracked at third: $TRIAL_CRACKED_AT_THIRD"
            QUERY_PARAMS+="&trial_cracked_at_third=$TRIAL_CRACKED_AT_THIRD"
        fi

        if [ -n "$TRIAL_CRACKED_AT" ]; then
            echo -e "Trial cracked at: $TRIAL_CRACKED_AT"
            QUERY_PARAMS+="&trial_cracked_at=$TRIAL_CRACKED_AT"
        fi

        if [ -n "$TRIAL_FIXED_NOTICE_AT" ]; then
            echo -e "Trial fixed notice at: $TRIAL_FIXED_NOTICE_AT"
            QUERY_PARAMS+="&trial_fixed_notice_at=$TRIAL_FIXED_NOTICE_AT"
        fi

        if [ -n "$TRIAL_FIXED_AT" ]; then
            echo -e "Trial fixed at: $TRIAL_FIXED_AT"
            QUERY_PARAMS+="&trial_fixed_at=$TRIAL_FIXED_AT"
        fi

        RESPONSE=$(curl --location --globoff --request POST "$API_DOMAIN/api/external_users/claims/advocates/final?$QUERY_PARAMS")

        if jq -e 'type == "array" and .[0].error' <<< "$RESPONSE" > /dev/null; then
            ERROR_MSG=$(jq -r '.[0].error' <<< "$RESPONSE")
            echo -e "\nRESPONSE:$RESPONSE"
            echo -e "\n>>> Error creating claim: $ERROR_MSG"
        else
            echo -e "\nRESPONSE:$RESPONSE"
            echo -e "\n>>> Claim created successfully."

            # Parse CLAIM_ID from response
            CLAIM_ID=$(jq -r '.id' <<< "$RESPONSE")
            echo -e "=> CLAIM_ID: $CLAIM_ID"
        fi

        unset RESPONSE
    fi

    # Create Defendant
    if [ "$DEFENDANT_FLAG" == "TRUE" ]; then
        echo -e "\n>>> Creating Defendant..."
        RESPONSE=$(curl -s --location --globoff --request POST "$API_DOMAIN/api/external_users/defendants?claim_id=$CLAIM_ID&first_name=$FIRST&last_name=$LAST&date_of_birth=$DOB&api_key=$API_KEY")

        echo -e "\nRESPONSE:$RESPONSE"

        if jq -e 'type == "array" and .[0].error' <<< "$RESPONSE" > /dev/null; then
            ERROR_MSG=$(jq -r '.[0].error' <<< "$RESPONSE")
            echo -e "\n>>> Error creating claim: $ERROR_MSG"
        else
            echo -e "\n>>> Defendant created successfully."

            # Parse DEFENDANT_ID from response
            DEFENDANT_ID=$(jq -r '.id' <<< "$RESPONSE")
            echo -e "=> DEFENDANT_ID: $DEFENDANT_ID"
        fi

        unset RESPONSE

        # Create Rep Order
        echo -e "\n>>> Creating Representation Order..."
        RESPONSE=$(curl -s --location --globoff --request POST "$API_DOMAIN/api/external_users/representation_orders?defendant_id=$DEFENDANT_ID&maat_reference=$MAAT_REF&representation_order_date=$REP_ORDER_DATE&api_key=$API_KEY")
        
        echo -e "\nRESPONSE:$RESPONSE"

        if jq -e 'type == "array" and .[0].error' <<< "$RESPONSE" > /dev/null; then
            ERROR_MSG=$(jq -r '.[0].error' <<< "$RESPONSE")            
            echo -e "\n>>> Error creating claim: $ERROR_MSG"
        else
            echo -e "\n>>> Representation Order created successfully."
        fi

        unset RESPONSE
    fi

    # Create Fee
    if [ "$FEE_FLAG" == "TRUE" ]; then
    echo -e "\n>>> Creating Fee..."
    
    QUERY_PARAMS="claim_id=$CLAIM_ID&fee_type_id=$FEE_TYPE_ID&api_key=$API_KEY"

    if [ -n "$QUANTITY" ]; then
        echo -e "Quantity: $QUANTITY"
        QUERY_PARAMS+="&quantity=$QUANTITY" 
    fi

    if [ -n "$RATE" ]; then
        echo -e "Rate: $RATE"
        QUERY_PARAMS+="&rate=$RATE" 
    fi

    if [ -n "$AMOUNT" ]; then
        echo -e "Amount: $AMOUNT"
        QUERY_PARAMS+="&amount=$AMOUNT" 
    fi

    RESPONSE=$(curl -s --location --globoff --request POST "$API_DOMAIN/api/external_users/fees/?$QUERY_PARAMS")

    echo -e "\nRESPONSE:$RESPONSE"

    if jq -e 'type == "array" and .[0].error' <<< "$RESPONSE" > /dev/null; then
        ERROR_MSG=$(jq -r '.[0].error' <<< "$RESPONSE")        
        echo -e "\n>>> Error creating claim: $ERROR_MSG"
    else
        echo -e "\n>>> Fee created successfully."
    fi

    unset RESPONSE
    fi

    # PARAM SET
    LAST_CLAIM_ID=$CLAIM_ID
    LAST_CASE_ID=$case_id
    LAST_FEE_ID=$fee_id
    LAST_DEFENDANT_ID=$defendant_id

    echo -e "\n==== End of item: $i"
done

echo -e "\n!=== ${0} ended..."