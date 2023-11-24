#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

# Display what kind of services are offered #) <service>
# get the services from the service table

MAIN_MENU() {
  
  echo "~~~ Welcome to my salon ~~~~"
  echo "How can I help you? \nChoose a service"

  # Display the services
  SERVICES=$($PSQL "SELECT service_id, name FROM services")

  echo -e "$SERVICES" | while read SERVICE_ID BAR NAME
    do
      echo "$SERVICE_ID) $NAME"
    done

  read SERVICE_ID_SELECTED

  # Check if the input is a valid number or the id is in the table 
  SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_ID ]]; then
    MAIN_MENU "Sorry couldn't find such option. Insert valid option"
  else 
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

    echo "What's your phone number?"
    read CUSTOMER_PHONE
    # check if the phone number is in customer table
    PHONE_IN_TABLE=$($PSQL "SELECT phone FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    if [[ -z $PHONE_IN_TABLE ]]; then 
      echo "I don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      # Update customers table 
      $($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
      # Get customer_id
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      echo "What time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
      read SERVICE_TIME
      # update the appointments table
      $($PSQL "INSERT INTO appointments(customer_id,service_id, time) VALUES($CUSTOMER_ID,$SERVICE_ID,'$SERVICE_TIME')")
      echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    else # this means there's a register for that user
      # Get customer_id
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      echo "What time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
      read SERVICE_TIME
      # update the appointments table
      $($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME')")
      echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    fi  
  fi         
}

MAIN_MENU
 
