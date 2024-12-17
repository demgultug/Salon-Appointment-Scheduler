#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "\nWelcome to My Salon, how can I help you?\n"


# display the services
SERVICE_MENU () {
SERVICES=$($PSQL "SELECT service_id, name FROM services")
echo "$SERVICES" | while read SERVICE_ID NAME 
do
echo "$SERVICE_ID) $NAME" | sed 's/ |//'
done
}

SERVICE_MENU
read SERVICE_ID_SELECTED

# if the service does not exist
SERVICE=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
while  [[ -z $SERVICE ]]
do
echo "I could not find that service. What would you like today?"
SERVICE_MENU
read CUSTOMER_CHOICE
SERVICE=$($PSQL "SELECT service_id FROM services WHERE service_id = $CUSTOMER_CHOICE")
done

# get customer info
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

# if customer is not registered
if [[ -z $CUSTOMER_ID ]] 
then 
echo "I don't have a record for that phone number, what's your name?"
read CUSTOMER_NAME
INSERT_NEW_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
else 
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID")
fi

# ask for appointment time
echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME?"
read SERVICE_TIME
# insert appointments
APPOINTMENT=$($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES('$SERVICE_TIME', $CUSTOMER_ID, $SERVICE)")
# reservation confirmation 
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE")

echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."


