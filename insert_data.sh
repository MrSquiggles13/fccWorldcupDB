#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

ADD_TEAM="insert into teams(name) values"
ADD_GAME="insert into games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) values"
while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]]
  then
    # add winner and opponent to teams if not there
    WINNER_ID_RESULT=$($PSQL "select team_id from teams where name='$WINNER'")
    OPPONENT_ID_RESULT=$($PSQL "select team_id from teams where name='$OPPONENT'")

    if [[ -z $WINNER_ID_RESULT ]]
    then
      $PSQL "$ADD_TEAM('$WINNER')"
    fi
    if [[ -z $OPPONENT_ID_RESULT ]]
    then
      $PSQL "$ADD_TEAM('$OPPONENT')"
    fi
    # else retrieve team id and put in foreign keys respectively

    WINNER_ID=$($PSQL "select team_id from teams where name='$WINNER'")
    OPPONENT_ID=$($PSQL "select team_id from teams where name='$OPPONENT'")

    ADD_GAME+="($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS),"

  fi
done <<< $(cat games.csv) 

ADD_GAME=$(echo $ADD_GAME | sed 's/.$//')
$PSQL "$ADD_GAME"

# create table teams(team_id serial primary key not null, name varchar(60) unique not null);

# create table games(game_id serial primary key not null, year int not null, round varchar(60) not null, winner_id int not null, opponent_id int not null, winner_goals int not null, opponent_goals int not null);








