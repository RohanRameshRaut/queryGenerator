/*
-BLOB is a data type in sqlite, which can be used to store raw bytes as it is, it manages size automatically. 
-just check for size while inserting so you dont end up inserting too much.
-for 1 byte information we can use varchar(1) or BLOB also.
- we'll make the primary key from the data itselft, we'll use ID as pk when composite pk is too big

----v03---
-we'll pack multiple values inside one byte i.e varchar(1), for instance we can store pk in first 5bit & fk in last 3bit as shown in Plyer table.
Storing Example: playerID = 20 (5-bit) and teamID = 5 (3-bit)
	Combined byte = (20 << 3) | 5 = 165
	INSERT INTO Player (playerID, playerName, teamID) VALUES (char((20 << 3) | 5), 'Rahul', 'A');

	why char type?
	- Because VARCHAR(1) is a text column, not a numeric or raw binary column.
	- If you tried to insert the raw number 165 directly (e.g., VALUES (165, ...)), SQLite would store it as the text string '165', which takes up 3 characters (3 bytes) instead of a single byte.
	- The char() function tells SQLite: "Take the integer byte value 165, convert it into its single-byte character representation, and store that character inside the VARCHAR(1) column."

unpack values:
SELECT 
    playerName,
    (unicode(playerID) >> 3) & 31 AS playerID_val, -- extracts the 5 bits
    unicode(playerID) & 7 AS teamID_val           -- extracts the 3 bits
FROM Player;

	why unicode?
	- Because SQLite stores it as a character, you use the unicode() function to extract the integer and bitwise operators to split them back out
rote:(pk = PRIMARY KEY, fk = FOREIGN KEY)
assumpitons: match exception Test 
*/

CREATE TABLE Team (
    teamID VARCHAR(1) PRIMARY KEY,--1bit = teamID, 7bit waste
    teamName VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Player (
    playerID VARCHAR(1),--1st 4bits = palyerID pk, last 1bit = teamID fk, 3bit waste
    playerName VARCHAR(50) NOT NULL,
    --teamID VARCHAR(1) NOT NULL REFERENCES Team(teamID)
);

CREATE TABLE Match (
	matchID VARCHAR(1), --1bit = matchID, 3bit = matchType, 1bit = team1ID, 1bit = team2ID, 1bit = tossWinnerID, 1bit = matchWinnerID
--	matchType VARCHAR(1) NOT NULL,
--	team1 VARCHAR(1) NOT NULL REFERENCES Team(teamID),
--	team2 VARCHAR(1) NOT NULL REFERENCES Team(teamID),
	date VARCHAR(3), --18bit = date, 1bit = matchResult(win/draw), 1bit = tossDecision(bat/ball), 4bit remaining
	venue VARCHAR(50) NOT NULL,
	--matchResult VARCHAR(1) NOT NULL,
--	matchWinner VARCHAR(1) REFERENCES Team(teamID),
--	tossDecision VARCHAR(1) NOT NULL,
--	tossWinner VARCHAR(1) NOT NULL REFERENCES Team(teamID)
--	pk(matchID)
);

CREATE TABLE Inning (
--    inningNo VARCHAR(1) NOT NULL PRIMARY KEY CHECK (inningNo IN (1, 2)),
--    matchID VARCHAR(1) NOT NULL REFERENCES Match(matchID),
--    teamID VARCHAR(1) NOT NULL REFERENCES Team(teamID),
--    runs VARCHAR(2) NOT NULL CHECK (runs >= 0)
	value VARCHAR(2) --1bit = inningNo, 1bit = matchID, 1bit = teamID, 10bit = runs, 3bit waste
	--(pk(inningNo))
);

CREATE TABLE Over (
--	inningNo VARCHAR(1) NOT NULL REFERENCES Inning(inningNo),
--	overNumber VARCHAR(1) NOT NULL CHECK (overNumber >= 0),
--	bowler VARCHAR(1) NOT NULL REFERENCES Player(playerID),
--	runs VARCHAR(1) NOT NULL CHECK (runs >= 0),
--	PRIMARY KEY (inningNo, overNumber)
	value VARCHAR(3) --1bit = inningNo, 6bit = overNumber, 4bit = bowlerID, 6bit = runs, 7bit waste
	--(pk(inningNo, overNumber))
);

CREATE TABLE Delivery (
	--inningNo VARCHAR(1) NOT NULL REFERENCES Inning(inningNo),
	--overNumber VARCHAR(1) NOT NULL CHECK (overNumber >= 0),
	--deliveryNo VARCHAR(1) NOT NULL CHECK (deliveryNo >= 0),
	--striker VARCHAR(1) NOT NULL REFERENCES Player(playerID),
	--nonStriker VARCHAR(1) NOT NULL REFERENCES Player(playerID),
	--PRIMARY KEY (inningNo, overNumber, deliveryNo), --here we should use deliveryID as pk which is 1 byte only
	--FOREIGN KEY (inningNo, overNumber) REFERENCES Over(inningNo, overNumber)
	value VARCHAR(3) --1bit = inningNo, 6bit = overNumber, 4bit = deliveryNo, 1bit = strikerID, 1bit = nonStrikerID, 3bit = strikerRuns, 3bit = extras, 5bit waste
	--(pk(inningNo, overNumber, deliveryNo))
);

CREATE TABLE Wicket (
--	wicketID VARCHAR(1) PRIMARY KEY,
--	playerOut VARCHAR(1) NOT NULL REFERENCES Player(playerID),
--	fielder VARCHAR(1) REFERENCES Player(playerID),
	kind varchar(20) NOT NULL,
--	inningNo VARCHAR(1) NOT NULL REFERENCES Inning(inningNo),
--	overNumber VARCHAR(1) NOT NULL CHECK (overNumber >= 0),
--	deliveryNo VARCHAR(1) NOT NULL CHECK (deliveryNo >= 0),
--	FOREIGN KEY (inningNo, overNumber, deliveryNo) REFERENCES Delivery(inningNo, overNumber, deliveryNo)
	value VARCHAR(3) --1bit = inningNo, 6bit = overNumber, 4bit = deliveryNo, 4bit = playerOutID, 4bit = fielderID, 5bit waste
	--(pk(inningNo, overNumber, deliveryNo))
);
