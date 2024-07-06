#!/bin/bash

# Function to display services
display_services() {
  echo "Here are the services we offer:"
  SERVICES=$(psql --username=freecodecamp --dbname=salon -t -c "SELECT service_id, name FROM services ORDER BY service_id;")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME; do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
}

# Function to prompt for service ID
prompt_service_id() {
  echo "Please enter the service ID you would like:"
  read SERVICE_ID_SELECTED
  SERVICE_EXISTS=$(psql --username=freecodecamp --dbname=salon -t -c "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED;")
  if [[ -z $SERVICE_EXISTS ]]; then
    echo "Invalid service ID. Please try again."
    display_services
    prompt_service_id
  fi
}

# Function to prompt for customer details
prompt_customer_details() {
  echo "Please enter your phone number:"
  read CUSTOMER_PHONE
  CUSTOMER_NAME=$(psql --username=freecodecamp --dbname=salon -t -c "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE';")
  if [[ -z $CUSTOMER_NAME ]]; then
    echo "It looks like you are a new customer. Please enter your name:"
    read CUSTOMER_NAME
    psql --username=freecodecamp --dbname=salon -c "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE');"
  else
    CUSTOMER_NAME=$(echo $CUSTOMER_NAME | xargs) # Trim whitespace
  fi
}

# Function to prompt for appointment time
prompt_appointment_time() {
  echo "Please enter the appointment time:"
  read SERVICE_TIME
}

# Main script execution
display_services
prompt_service_id
prompt_customer_details
prompt_appointment_time

CUSTOMER_ID=$(psql --username=freecodecamp --dbname=salon -t -c "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")
SERVICE_NAME=$(psql --username=freecodecamp --dbname=salon -t -c "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")

psql --username=freecodecamp --dbname=salon -c "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');"

echo "I have put you down for a $(echo $SERVICE_NAME | xargs) at $SERVICE_TIME, $CUSTOMER_NAME."