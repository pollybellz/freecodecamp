#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Extract unique countries and insert into DB
tr -d '\r' < games.csv |
awk -F',' 'NR>1 {print $3; print $4}' |
sort -u |
while read -r country
do
  $PSQL "INSERT INTO teams(name) VALUES('$country');"
done

# Extract unique games and insert into DB
# Read CSV and insert into games
tail -n +2 games.csv | while IFS=',' read -r year round winner opponent winner_goals opponent_goals
do
  # get team ids
  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$winner';")
  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent';")

  # clean whitespace/newlines
  WINNER_ID=$(echo $WINNER_ID | xargs)
  OPPONENT_ID=$(echo $OPPONENT_ID | xargs)

  # insert into games
  $PSQL "
    INSERT INTO games(
      year,
      round,
      winner_id,
      opponent_id,
      winner_goals,
      opponent_goals
    )
    VALUES(
      $year,
      '$round',
      $WINNER_ID,
      $OPPONENT_ID,
      $winner_goals,
      $opponent_goals
    );
  "
done