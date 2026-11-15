/*
-BLOB is a data type in sqlite, which can be used to store raw bytes as it is, it manages size automatically. 
-just check for size while inserting so you dont end up inserting too much.
-for 1 byte information we can use varchar(1) or BLOB also.
- we'll go with the varchar(1) cause it would be hard to query on BLOB as dmk sir mentioned .
- we'll make the primary key from the data itselft, we'll use ID as pk when composite pk is too big

*/

CREATE TABLE Team (
    teamID VARCHAR(1) PRIMARY KEY,
    teamName VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Player (
    playerID VARCHAR(1) PRIMARY KEY,
    playerName VARCHAR(50) NOT NULL,
    teamID VARCHAR(1) NOT NULL REFERENCES Team(teamID)
);

CREATE TABLE Match (
	matchID VARCHAR(1) PRIMARY KEY,
	matchType VARCHAR(1) NOT NULL,
	team1 VARCHAR(1) NOT NULL REFERENCES Team(teamID),
	team2 VARCHAR(1) NOT NULL REFERENCES Team(teamID),
	date VARCHAR(3) NOT NULL,
	venue VARCHAR(50) NOT NULL,
	matchResult VARCHAR(10) NOT NULL,
	matchWinner VARCHAR(1) REFERENCES Team(teamID),
	tossDecision VARCHAR(100) NOT NULL,
	tossWinner VARCHAR(1) NOT NULL REFERENCES Team(teamID)
);

CREATE TABLE Inning (
    inningNo VARCHAR(1) NOT NULL PRIMARY KEY CHECK (inningNo IN (1, 2)),
    matchID VARCHAR(1) NOT NULL REFERENCES Match(matchID),
    teamID VARCHAR(1) NOT NULL REFERENCES Team(teamID),
    runs VARCHAR(2) NOT NULL CHECK (runs >= 0)
);

CREATE TABLE Over (
	inningNo VARCHAR(1) NOT NULL REFERENCES Inning(inningNo),
	overNumber VARCHAR(1) NOT NULL CHECK (overNumber >= 0),
	bowler VARCHAR(1) NOT NULL REFERENCES Player(playerID),
	runs VARCHAR(1) NOT NULL CHECK (runs >= 0),
	PRIMARY KEY (inningNo, overNumber)
);

CREATE TABLE Runs (
	runsID VARCHAR(1) PRIMARY KEY,
	strikerRuns VARCHAR(1) NOT NULL CHECK (strikerRuns >= 0),
	extras VARCHAR(1) NOT NULL CHECK (extras >= 0),
	total VARCHAR(1) NOT NULL CHECK (total = extras + strikerRuns)
);

CREATE TABLE Delivery (
	inningNo VARCHAR(1) NOT NULL REFERENCES Inning(inningNo),
	overNumber VARCHAR(1) NOT NULL CHECK (overNumber >= 0),
	deliveryNo VARCHAR(1) NOT NULL CHECK (deliveryNo >= 0),
	striker VARCHAR(1) NOT NULL REFERENCES Player(playerID),
	nonStriker VARCHAR(1) NOT NULL REFERENCES Player(playerID),
	runsID VARCHAR(1) REFERENCES Runs(runsID),
	PRIMARY KEY (inningNo, overNumber, deliveryNo), --here we should use deliveryID as pk which is 1 byte only
	FOREIGN KEY (inningNo, overNumber) REFERENCES Over(inningNo, overNumber)
);

CREATE TABLE Wicket (
	wicketID VARCHAR(1) PRIMARY KEY,
	playerOut VARCHAR(1) NOT NULL REFERENCES Player(playerID),
	fielder VARCHAR(1) REFERENCES Player(playerID),
	kind varchar(20) NOT NULL,
	inningNo VARCHAR(1) NOT NULL REFERENCES Inning(inningNo),
	overNumber VARCHAR(1) NOT NULL CHECK (overNumber >= 0),
	deliveryNo VARCHAR(1) NOT NULL CHECK (deliveryNo >= 0),
	FOREIGN KEY (inningNo, overNumber, deliveryNo) REFERENCES Delivery(inningNo, overNumber, deliveryNo)
);
