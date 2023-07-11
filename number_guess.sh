#!/bin/bash

#### FUNCTIONS AND DEFINITONS ####
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# generate random number
NUMBER=$(( $RANDOM % 1000 + 1 ))
TRIES=0

check_user () {
    # if username does not exist
    if [[ -z $USER_QUERY ]]
    then
    # insert username, games_played, best_game (hacky 9999 as best_game; needs improvement)
        INSERT_USER="$(
            $PSQL "INSERT INTO users (username, games_played, best_game)
            VALUES ('$USER', 1, 9999)"
            )"
        USER_QUERY="$($PSQL "SELECT * FROM users WHERE username='$USER'")"
        echo $USER_QUERY | while IFS="|" read USER_ID USER GAMES_PLAYED BEST_GAME
        do
            echo -e "\nWelcome, $USER! It looks like this is your first time here."
        done

    else
        
        echo $USER_QUERY | while IFS="|" read USER_ID USER GAMES_PLAYED BEST_GAME
        do
            echo -e "\nWelcome back, $USER! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
            # if user exists, update the row with an additional game
            increment_games_played
            UPDATE_USER="$(
                $PSQL "UPDATE users
                SET games_played=$GAMES_PLAYED
                WHERE username = '$USER';"
                )"
        done
    fi
}

guess_loop () {
    while [[ $GUESS -ne $NUMBER ]]
    do
        # if the length of the argument is non-zero
        TRIES=$((TRIES+1))
        if [[ -n ${GUESS//[0-9]/} ]]
        then
            # ask for an integer
            echo -e "\nThat is not an integer, guess again:"
            read GUESS
        elif [[ $GUESS -gt $NUMBER ]]
        then
            # state the number is lower than the guess
            echo -e "\nIt's lower than that, guess again:"
            read GUESS
        elif [[ $GUESS -lt $NUMBER ]]
        then
            # state the number is higer thand the guess
            echo -e "\nIt's higher than that, guess again:"
            read GUESS
        fi
    done
}

right_answer() {
    # increment tries (make a function)
    TRIES=$((TRIES+1))
    
    # CONGRATS!
    echo -e "\nYou guessed it in $TRIES tries. The secret number was $NUMBER. Nice job!"

    # update database
    UPDATE_USER="$(
        $PSQL "UPDATE users
        SET best_game = $TRIES
        WHERE username = '$USER'
        AND best_game > $TRIES;"
        )"
}

increment_games_played () {
    GAMES_PLAYED=$((GAMES_PLAYED+1))
}

#### END FUNCTIONS AND DEFINITIONS ####

# First prompt for username and read
echo "Enter your username:"
read USER

# check username in db or update if doesn't exist
USER_QUERY="$($PSQL "SELECT * FROM users WHERE username='$USER'")"
check_user

# print "Guess the secret number between 1 and 1000:"
echo -e "\nGuess the secret number between 1 and 1000:"
read GUESS

guess_loop

# when the guess_loop breaks, they must have the right answer
# update the db
right_answer

