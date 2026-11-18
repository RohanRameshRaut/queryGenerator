
CREATE TABLE Team (
    teamID VARCHAR(1) PRIMARY KEY,
    teamName VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Player ( 
    playerID VARCHAR(1) PRIMARY KEY,
    teamID VARCHAR(1) REFERENCES Team(teamID), 
    playerName VARCHAR(50) NOT NULL
);

CREATE TABLE TeamPlayer (
	teamPlayer VARCHAR(1) PRIMARY KEY,
    	playerID VARCHAR(1) REFERENCES Player(playerID),
    	teamID VARCHAR(1) REFERENCES Player(teamID), 
);

CREATE TABLE Match (
	matchID VARCHAR(1) PRIMARY KEY,
	matchType VARCHAR(1) NOT NULL, 
	team1 VARCHAR(1) NOT NULL REFERENCES Team(teamID),
	team2 VARCHAR(1) NOT NULL REFERENCES Team(teamID),
	date VARCHAR(3) NOT NULL,
	venue VARCHAR(50) NOT NULL,
	Result VARCHAR(1), -- 1bit = matchResult(win/draw), 1bit = tossDecision(bat/ball)
	tossDecision VARCHAR(1) NOT NULL,
	matchWinner VARCHAR(1) REFERENCES Team(teamID),
	tossWinner VARCHAR(1) NOT NULL REFERENCES Team(teamID)
);

CREATE TABLE MatchInning (
	matchInning VARCHAR(1) PRIMARY KEY -- 1bit = inningNo, 1bit = matchID
);

CREATE TABLE Inning (
	matchInning VARCHAR(1) PRIMARY KEY REFERENCES MatchInning(matchInning),
	teamID VARCHAR(1) REFERENCES Team(teamID),
	runs VARCHAR(2) NOT NULL CHECK (runs >= 0)
);

CREATE TABLE OverInning (
	overInning VARCHAR(1) PRIMARY KEY -- 1bit = inningNo, 6bit = overNumber, 1bit = teamID
);

CREATE TABLE Over (
	overInning VARCHAR(1) PRIMARY KEY REFERENCES OverInning(overInning),
	bowler VARCHAR(1) NOT NULL REFERENCES TeamPlayer(teamPlayer),
	runs VARCHAR(1) NOT NULL CHECK (runs >= 0)
);

CREATE TABLE DeliveryBatsman( -- total 220 possible combinations so, 1byte would be enough to represent them
	deliveryBatsman VARCHAR(1) PRIMARY KEY,
	matchInning VARCHAR(1), REFERENCES Inning(matchInning),
	striker VARCHAR(1) REFERENCES TeamPlayer(teamPlayer), 
	nonStriker VARCHAR(1) REFERENCES TeamPlayer(teamPlayer)
);

CREATE TABLE Delivery (
	overInning VARCHAR(1) NOT NULL REFERENCES Over(overInning), 
	deliveryNo VARCHAR(1) NOT NULL,
	deliveryBatsman VARCHAR(1) NOT NULL REFERENCES DeliveryBatsman(deliveryBatsman),
	matchInning VARCHAR(1), REFERENCES DeliveryBatsman(matchInning),
	runs VARCHAR(1), --1st 3bit = strikerRuns, last 5bit = extras
	PRIMARY KEY (overInning, deliveryNo)
);

CREATE TABLE Wicket (
	overInning VARCHAR(1) NOT NULL REFERENCES Over(overInning), 
	deliveryNo VARCHAR(1), NOT NULL REFERENCES Delivery(deliveryNo),
	player VARCHAR(1) REFERENCES TeamPlayer(teamPlayer),
	fielder VARCHAR(1) REFERENCES TeamPlayer(teamPlayer),
	kind varchar(1) NOT NULL, -- there are total 12 kinds of dismissals, so we need 4bit
	PRIMARY KEY (overInning, deliveryNo, player)
);
