#!/bin/bash
#This is a program of setting up appointment in a hair salon with 3 services: cut hair, dye hair, style hair

#Allow to query the database in the script, remove the column names(-t)
PSQL="psql -t --username=freecodecamp --dbname=salon -c"

MAIN(){
  echo -e "\nWelcome to My Salon, how can I help you?\n"

  #Function to ask user for input on services which is saved to $SERVICE_ID_SELECTED
  CHECK_SELECTION_FROM_CUSTOMER

  #Get the Customer Info and Set up Appointment
  GET_CUSTOMER_INFORMATION_SET_UP_APPOINTMENT
}

#Function to print all the available services formatted in a way
DISPLAY_ALL_SERVICES(){
  #Use query to get information from the services table
  ALL_SERVICES="$($PSQL "SELECT service_id,name FROM services;")"

  #Printing out all the services in a certain format
  echo "$ALL_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    #Only print when there is a number for service id
    if [[ $SERVICE_ID =~ ^[0-9]+$ ]]
    then
      echo "$SERVICE_ID) $SERVICE_NAME"
    fi
  done
}

#Recursive Function that asks the customer for a valid service id number selection
CHECK_SELECTION_FROM_CUSTOMER(){

  DISPLAY_ALL_SERVICES
  #get customer input on the service that they want
  read SERVICE_ID_SELECTED

  #if the input is a number
  if [[ $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    #use to query on the services table to find if it exist
    SERVICE_ID_SEARCH=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")

    #if service not exist, reprint all services and call the function again
    if [[ -z $SERVICE_ID_SEARCH ]]
    then
      echo -e "\nI could not find that service. What would you like today?"
      CHECK_SELECTION_FROM_CUSTOMER
    else
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
    fi
  else
    #if not a number selection recall the function for a new input
    echo -e "\nI could not find that service. What would you like today?"
    CHECK_SELECTION_FROM_CUSTOMER
  fi
}

#Ask for customer information and then set up appointment to the table
GET_CUSTOMER_INFORMATION_SET_UP_APPOINTMENT(){
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  #Use Phone number to query about the customer id and name
  CUSTOMER_QUERY_RESULT=$($PSQL "SELECT customer_id,name FROM customers WHERE phone='$CUSTOMER_PHONE'")

  #If a new customer
  if [[ -z "$CUSTOMER_QUERY_RESULT" ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME

    #Add a new customer to table
    ADD_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name,phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE name='$CUSTOMER_NAME'")
  
  else
    #Get the information of a stored customer
    read CUSTOMER_ID BAR CUSTOMER_NAME <<< $CUSTOMER_QUERY_RESULT
  fi
  #get the time for the service
  echo -e "\nWhat time would you like to do that service?"
  read SERVICE_TIME

  #Add the appointment 
  ADD_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(name,customer_id,service_id,time) VALUES('$CUSTOMER_NAME','$CUSTOMER_ID','$SERVICE_ID_SELECTED','$SERVICE_TIME')")
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}

echo -e "\n~~~~~ My Salon ~~~~~"
MAIN
