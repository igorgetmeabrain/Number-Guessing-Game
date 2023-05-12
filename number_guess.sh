#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=number_guess -t -c"

echo "Enter your username:"
read NAME

USER_INFO=$($PSQL "SELECT name, games_played, best_game FROM users WHERE name='$NAME'")

if [[ -z $USER_INFO ]]
then
  echo "Welcome, $NAME! It looks like this is your first time here."
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(name, games_played, best_game) VALUES('$NAME', 0, 0)")
else
  echo "$USER_INFO" | while read USERNAME BAR GAMES_PLAYED BAR BEST_GAME
  do
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done 
fi

#get random number
NUMBER=$(( RANDOM % 1000 + 1 ))
SCORE=0
#play game
echo "Guess the secret number between 1 and 1000:"


while [[ $GUESS != $NUMBER ]]
do
  (( SCORE++ ))
  read GUESS
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  elif [[ $GUESS -gt $NUMBER ]]
  then
    echo "It's lower than that, guess again:"
  elif [[ $GUESS -lt $NUMBER ]]
  then
    echo "It's higher than that, guess again:"
  fi
done

#update games_played
UPDATE_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played=games_played+1 WHERE name='$NAME'")
#update best_game
BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE name='$NAME'")

if [ $BEST_GAME == 0 ] || [ $SCORE -lt $BEST_GAME ]
then
  UPDATE_BEST_SCORE=$($PSQL "UPDATE users SET best_game=$SCORE WHERE name='$NAME'")
fi
echo "You guessed it in $SCORE tries. The secret number was $NUMBER. Nice job!"
