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

CREATE TABLE Player ( -- check v03 for optimal
    playerID VARCHAR(1) PRIMARY KEY,
    playerName VARCHAR(50) NOT NULL,
    teamID VARCHAR(1) NOT NULL REFERENCES Team(teamID)
    /*
     playerNteam VARCHAR(1) PRIMARY KEY, -- 1bit = teamID, 4bit = playerNumber, 3bit waste
     we won't be able to write teamID as a foreign key then?
    */
);

CREATE TABLE Match ( -- check v03 for optimal
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

CREATE TABLE Inning ( -- check v03 for optimal
--    inningNo VARCHAR(1) PRIMARY KEY
--    matchID VARCHAR(1) NOT NULL REFERENCES Match(matchID),
--    teamID VARCHAR(1) NOT NULL REFERENCES Team(teamID),
	-- same here, we won't be able to write FK here
	inningNo VARCHAR(1) PRIMARY KEY, -- 1bit = inningNo, 1bit = matchID, 1bit = teamID, 5bit waste
	runs VARCHAR(2) NOT NULL CHECK (runs >= 0)
);

CREATE TABLE Over (
--	inningNo VARCHAR(1) NOT NULL REFERENCES Inning(inningNo),
--	overNumber VARCHAR(1) NOT NULL CHECK (overNumber >= 0),
	overInning VARCHAR(1) PRIMARY KEY, -- 1bit = inningNo, 6bit = overNumber, 1bit waste
	bowler VARCHAR(1) NOT NULL REFERENCES Player(playerID), -- 5bit = bowler(1bit for team), 3bit waste
	runs VARCHAR(1) NOT NULL CHECK (runs >= 0),
--	PRIMARY KEY (inningNo, overNumber)
);

CREATE TABLE Runs ( --8bit
--	strikerRuns VARCHAR(1) NOT NULL CHECK (strikerRuns >= 0),
--	extras VARCHAR(1) NOT NULL CHECK (extras >= 0),
	runs VARCHAR(1) PRIMARY KEY --1st 3bit = strikerRuns, last 5bit = extras
--	total VARCHAR(1) NOT NULL CHECK (total = extras + strikerRuns)
);

CREATE TABLE Delivery ( -- 30bit
--	inningNo VARCHAR(1) NOT NULL REFERENCES Inning(inningNo),
--	overNumber VARCHAR(1) NOT NULL CHECK (overNumber >= 0),
	overInning VARCHAR(1) NOT NULL REFERENCES Over(overInning), 
--	deliveryNo VARCHAR(1) NOT NULL CHECK (deliveryNo >= 0),
--	striker VARCHAR(1) NOT NULL REFERENCES Player(playerID),
--	nonStriker VARCHAR(1) NOT NULL REFERENCES Player(playerID),
	deliveryBatsman VARCHAR(2), -- deliveryNo = 4bit, striker = 5bit(1bit for team), nonStriker = 5bit(1bit for team), 2bit waste
--	runsID VARCHAR(1) REFERENCES Runs(runsID),
	runs VARCHAR(1) REFERENCES Runs(runs) --1st 3bit = strikerRuns, last 5bit = extras
--	PRIMARY KEY (inningNo, overNumber, deliveryNo), --here we should use deliveryID as pk which is 1 byte only
--	FOREIGN KEY (inningNo, overNumber) REFERENCES Over(inningNo, overNumber)
	PRIMARY KEY (overInning, deliveryBatsman)
);

CREATE TABLE Wicket ( -- check v03 for optimal
--	inningNo VARCHAR(1) NOT NULL REFERENCES Inning(inningNo),
--	overNumber VARCHAR(1) NOT NULL CHECK (overNumber >= 0),
--	deliveryNo VARCHAR(1) NOT NULL CHECK (deliveryNo >= 0),
--	playerOut VARCHAR(1) NOT NULL REFERENCES Player(playerID),
	wicketID VARCHAR(2) PRIMARY KEY, -- 1bit = inningNo, 6bit = overNumber, 4bit = deliveryNo, 5bit = playerOutID,
	fielder VARCHAR(1) REFERENCES Player(playerID), -- 5bit = playerID, 3bit waste
	kind varchar(1) NOT NULL, -- there are total 12 kinds of dismissals, so we need 4bit
--	FOREIGN KEY (inningNo, overNumber, deliveryNo) REFERENCES Delivery(inningNo, overNumber, deliveryNo)
);
