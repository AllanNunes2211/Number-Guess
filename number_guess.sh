#!/bin/bash

# Connect to the PostgreSQL database
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Generate a random number between 1 and 1000
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

# Prompt user for username
echo "Enter your username:"
read USERNAME

# Check if username exists in database
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

# If user exists
if [[ -n $USER_ID ]]
then
  # Get games played and best game
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=$USER_ID")
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id=$USER_ID")
  
  # Welcome back message
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
else
  # Add new user to database
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
  
  # Welcome new user message
  echo "Welcome, $USERNAME! It looks like this is your first time here."
fi

# Game logic
echo "Guess the secret number between 1 and 1000:"
NUMBER_OF_GUESSES=0
GUESSED=false

while [[ $GUESSED == false ]]
do
  read GUESS
  
  # Check if input is an integer
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    continue
  fi
  
  # Increment number of guesses
  (( NUMBER_OF_GUESSES++ ))
  
  # Check the guess
  if [[ $GUESS -eq $SECRET_NUMBER ]]
  then
    GUESSED=true
  elif [[ $GUESS -gt $SECRET_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
  else
    echo "It's higher than that, guess again:"
  fi
done

# Record the game in the database
INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, guesses) VALUES($USER_ID, $NUMBER_OF_GUESSES)")

# Game completed message
echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
