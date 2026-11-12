CREATE TABLE Team (
    teamID INT PRIMARY KEY,
    teamName VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Player (
    playerID INT PRIMARY KEY,
    playerName VARCHAR(100) NOT NULL,
    teamID INT NOT NULL REFERENCES Team(teamID)
);

CREATE TABLE Match_Type (
    matchTypeId INT PRIMARY KEY,
    type VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Match (
    matchID INT PRIMARY KEY,
    matchTypeID INT NOT NULL REFERENCES Match_Type(matchTypeId),
    team1 INT NOT NULL REFERENCES Team(teamID),
    team2 INT NOT NULL REFERENCES Team(teamID),
    date DATE NOT NULL,
    venue VARCHAR(100) NOT NULL
);

CREATE TABLE Match_Result (
	resultID INT PRIMARY KEY,
    	matchID INT NOT NULL REFERENCES Match(matchID),
	matchResult VARCHAR(100) NOT NULL,
	matchWinner INT REFERENCES Team(teamID)
);

CREATE TABLE Toss_Result (
	tossResultID INT PRIMARY KEY,
    	matchID INT NOT NULL REFERENCES Match(matchID),
	tossDecision VARCHAR(100) NOT NULL,
	tossWinner INT NOT NULL REFERENCES Team(teamID)
);

CREATE TABLE Inning (
    inningID INT PRIMARY KEY,
    matchID INT NOT NULL REFERENCES Match(matchID),
    inningNo INT NOT NULL CHECK (inningNo IN (1, 2)),
    teamID INT NOT NULL REFERENCES Team(teamID),
    runs INT NOT NULL CHECK (runs >= 0)
);

CREATE TABLE Over (
	overID INT PRIMARY KEY,
	inningID INT NOT NULL REFERENCES Inning(inningID),
	overNumber INT NOT NULL CHECK (overNumber >= 0),
	bowler INT NOT NULL REFERENCES Player(playerID),
	runs INT NOT NULL CHECK (runs >= 0)
);

CREATE TABLE Wicket (
	wicketID INT PRIMARY KEY,
	playerOut INT NOT NULL REFERENCES Player(playerID),
	fielder INT REFERENCES Player(playerID),
	kind varchar(50) NOT NULL
);

CREATE TABLE Runs (
	runsID INT PRIMARY KEY,
	strikerRuns INT NOT NULL CHECK (strikerRuns >= 0),
	extras INT NOT NULL CHECK (extras >= 0),
	total INT NOT NULL CHECK (total = extras + strikerRuns)
);

CREATE TABLE Delivery (
	deliveryID INT PRIMARY KEY,
	overID INT NOT NULL REFERENCES Over(overID),
	deliveryNo INT NOT NULL CHECK (deliveryNo >= 0),
	striker INT NOT NULL REFERENCES Player(playerID),
	nonStriker INT NOT NULL REFERENCES Player(playerID)
	runsID INT REFERENCES Runs(runsID),
	wicketID INT REFERENCES Wicket(wicketID)
);

