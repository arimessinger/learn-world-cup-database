#! /bin/bash


if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $WINNER == "winner" ]]; then
    continue
  fi

  TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
  
  if [[ -z $TEAM_ID ]]
  then
    INSERT_TEAM=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
  fi

  TEAM_ID_OPPONENT=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

  if [[ -z $TEAM_ID_OPPONENT ]]
  then
    INSERT_TEAM=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
    TEAM_ID_OPPONENT=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
  fi

  GAME_EXISTS=$($PSQL "SELECT game_id FROM games WHERE year=$YEAR AND round='$ROUND' AND winner_id=$TEAM_ID AND opponent_id=$TEAM_ID_OPPONENT")
  
  if [[ -z $GAME_EXISTS ]]
  then
    INSERT_GAME=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) 
    VALUES($YEAR, '$ROUND', $TEAM_ID, $TEAM_ID_OPPONENT, $WINNER_GOALS, $OPPONENT_GOALS)")
  fi
done
