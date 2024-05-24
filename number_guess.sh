#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
# generate random number 1-1000
RANDOM_NUMBER=$((RANDOM % 1000 + 1))

GAME(){
  # get username
  echo "Enter your username:"
  read USERNAME

  # find player_id
  PLAYER_ID=$($PSQL "SELECT player_id FROM players WHERE username = '$USERNAME';")

  if [[ -z $PLAYER_ID ]]
  then
    # add new player and get the id
    RESULT=$($PSQL "INSERT INTO players(username) VALUES ('$USERNAME');")
    PLAYER_ID=$($PSQL "SELECT player_id FROM players WHERE username = '$USERNAME';")
    echo "Welcome, $USERNAME! It looks like this is your first time here."
  else
    # get player stats
    GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games LEFT JOIN players USING(player_id) WHERE player_id = $PLAYER_ID;")
    BEST_GAME_GUESSES=$($PSQL "SELECT MIN(guesses) FROM games LEFT JOIN players USING(player_id) WHERE player_id = $PLAYER_ID;")
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME_GUESSES guesses."
  fi

  # read first player guess
  echo "Guess the secret number between 1 and 1000:"
  read GUESS
  GUESSES=1

  # repeat until guess is right
  while [[ $GUESS != $RANDOM_NUMBER ]]
  do
    if [[ ! $GUESS =~ ^([0-9]+)$ ]]
    then
      echo "That is not an integer, guess again:"
    elif [[ $GUESS -lt $RANDOM_NUMBER ]]
    then
      echo "It's higher than that, guess again:"
      GUESSES=$(( $GUESSES + 1 ))
    else
      echo "It's lower than that, guess again:"
      GUESSES=$(( $GUESSES + 1 ))
    fi
    read GUESS
  done

  # save game stats
  RESULT=$($PSQL "INSERT INTO games(guesses, player_id) VALUES ($GUESSES, $PLAYER_ID);")

  # winning message
  echo "You guessed it in $GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!"
}

GAME
