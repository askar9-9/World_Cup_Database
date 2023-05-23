#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL "DROP TABLE teams,games;")

echo $($PSQL "CREATE TABLE teams (team_id SERIAL PRIMARY KEY,name VARCHAR UNIQUE NOT NULL);")

echo $($PSQL "CREATE TABLE games (
  game_id SERIAL PRIMARY KEY,
  year INT NOT NULL,
  round VARCHAR NOT NULL,
  winner_id INT NOT NULL,
  opponent_id INT NOT NULL,
  winner_goals INT NOT NULL,
  opponent_goals INT NOT NULL,
  FOREIGN KEY (winner_id) REFERENCES teams (team_id),
  FOREIGN KEY (opponent_id) REFERENCES teams (team_id)
);")

# Do not change code above this line. Use the PSQL variable above to query your database.
echo "$($PSQL "TRUNCATE TABLE games, teams")"

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
if [[ $YEAR != "year" ]]
then
  
  WINNER_TEAM="$($PSQL "SELECT * FROM teams WHERE name='$WINNER'")"
 
  if [[ -z $WINNER_TEAM ]]
  then
  
    INSERT_WINNER="$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")"
    
    if [[ $INSERT_WINNER == "INSERT 0 1" ]]
    then
      echo Inserted $WINNER successfully!
    else 
      echo failed to insert $WINNER!
    fi
  else
    echo $WINNER already exists
  fi


    OPPONENT_TEAM="$($PSQL "SELECT * FROM teams WHERE name='$OPPONENT'")"
  
  if [[ -z $OPPONENT_TEAM ]]
  then
    INSERT_OPPONENT="$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")"
    
    if [[ $INSERT_OPPONENT == "INSERT 0 1" ]]
    then
      echo Inserted $OPPONENT successfully!
    else
      echo Failed to insert $OPPONENT!
    fi
  else
    echo $OPPONENT already exists
  fi

  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
  
  INSERT_GAME="$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")"
  
  if [[ $INSERT_GAME == "INSERT 0 1" ]]
  then
    echo Game data inserted Successfully!
  else
    echo Failed to insert game data!
  fi
fi
done

