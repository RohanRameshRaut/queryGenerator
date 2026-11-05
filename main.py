'''
will create a match as dictionary having everything we need and teams is a list of dictionary 
teams will have (name, players[])
inning will have (team, overs[])
overs will have (overNo, deliveries[])
deliveries will have (deliveryNo, nonStriker, batsman, bowler, batsmanRuns, extrasRuns, totalRuns)
'''
import sys #direct line of communication btw python code and os

Match = {
	"matchID": 1,
	"matchType": None,
	"teams":[],
	"date": None,
	"venue": None,
	"matchResult": None,
	"matchWinner": None,
	"tossWinner": None,
	"tossDecision": None,
	"inning": [],#will contain the 1st and 2nd inning
}

if len(sys.argv) < 2:
	print("Argv Error")
	sys.exit(1)

file_path = sys.argv[1]

with open(file_path, "r") as file:
	lines = file.readlines()

key = ["dates:" , "match_type:", "outcome:", "winner:", "by:", "runs:", "players:",
"teams:", "toss:", "decision:", "venue:", "innings:", "1st innings:", "deliveries:",
"batsman:", "non_striker:", "bowler:", "extras:", "total:", "registry:", "2nd innings:", "team:"]
startPattern = "- "
found = [False] * 5 #list of 5 false values for flags

for line in lines: #get everything before the innings except players, we need teams before that!
	line = line.strip()

	if line == key[0]:
		found[0] = True
	elif found[0] and line.startswith(startPattern):
		found[0] = False
		Match["date"] = line.strip("- '")
	
	if line == key[1]:
		Match["matchType"] = line.split(":")[1].strip()

	if line == key[2]:
		found[1] = True
	elif found[1] and line.startswith(key[3]):
		found[1] = False
		Match["matchResult"] = "win"
		Match["matchWinner"] = line.split(":")[1].strip()

	if line == key[7]:
		found[2] = True
	elif found[2] and line.startswith(startPattern):
		Match["teams"].append({"name": line.split("-", 1)[1].strip(),"players": []})

		if len(Match["teams"]) == 2:
			found[2] = False

	if line == key[8]:
		found[3] = True
	elif found[3] and line.startswith(key[3]):
		Match["tossWinner"] = line.split(":")[1].strip()
	elif found[3] and line.startswith(key[9]):
		#found[3] = False , might be on previous line or next line. winner and decision won't come later so doesn't matter.
		Match["tossDecision"] = line.split(":")[1].strip()

	if key[10] in line:
		Match["venue"] = line.split(":", 1)[1].strip()
	
	if "overs:" in line:
		if line.split(":",1)[1].strip() == "50":
			Match["matchType"] = "ODI"
		elif line.split(":")[1].strip() == "20":
			Match["matchType"] = "T20"



#get the players

found = [False] * 3 #list of 3 false values for flags
teamNo = -1

for line in lines:
	line = line.strip()

	if line == key[19]:#registry
		found[0] = False
		break;

	if line == key[6]:#players
		found[0] = True

	if found[0]:
		if Match["teams"][0]["name"] in line:
			teamNo = 0
		elif Match["teams"][1]["name"] in line:
			teamNo = 1

	if found[0] and teamNo != -1:
		if line.startswith(startPattern):
			Match["teams"][teamNo]["players"].append(line.strip("- "))


#get the innings

found = [False] * 3 #list of 3 false values for flags

for line in lines: #get everything from the innings 
	line = line.strip()

	if key[20] in line: #2nd innings
		found[2] = True
		found[1] = False 
	if key[11] in line: #innings
		found[0] = True
	if found[0] and key[12] in line: #1st innings
		found[1] = True
	if (found[1] or found[2]) and line.startswith(key[21]):
		team = line.split(":", 1)[1].strip()#record the 1st inning team name
		Match["inning"].append({"team": team, "overs": []})


#get overs, deliveries and delivery details
overNo = -1
currentInning = -1
currentDelivery = None

for line in lines:
	line = line.strip()

	if key[12] in line: #1st innings
		currentInning = 0
		overNo = -1
		currentDelivery = None
	elif key[20] in line: #2nd innings
		currentInning = 1
		overNo = -1
		currentDelivery = None
	
	if currentInning != -1:
		if line.endswith(".1:") and line.startswith(startPattern):
			overNo += 1
			currentDelivery = None
			extractedOverNo = line.split(".", 1)[0].replace("-", "").strip()
			Match["inning"][currentInning]["overs"].append({"overNo": extractedOverNo, "deliveries": []})

		if line.startswith(startPattern) and "." in line:
			deliveryNo = line.split(".", 1)[1].strip("- ").split(":")[0].strip()
			currentDelivery = {"deliveryNo": deliveryNo, "nonStriker": None, "batsman": None, "bowler": None, "batsmanRuns": None, "extrasRuns": None, "totalRuns": None}

			if overNo >= 0 and len(Match["inning"][currentInning]["overs"]) > overNo:
				Match["inning"][currentInning]["overs"][overNo]["deliveries"].append(currentDelivery)

		if currentDelivery is not None:
			if line.startswith(key[14]) and not line[-1].isdigit():
				currentDelivery["batsman"] = line.split(":", 1)[1].strip()
			elif line.startswith(key[15]):
				currentDelivery["nonStriker"] = line.split(":", 1)[1].strip()
			elif line.startswith(key[16]):
				currentDelivery["bowler"] = line.split(":", 1)[1].strip()
			elif line.startswith(key[14]) and line[-1].isdigit():
				currentDelivery["batsmanRuns"] = line.split(":", 1)[1].strip()
			elif line.startswith(key[17]) and line[-1].isdigit():
				currentDelivery["extrasRuns"] = line.split(":", 1)[1].strip()
			elif line.startswith(key[18]) and line[-1].isdigit():
				currentDelivery["totalRuns"] = line.split(":", 1)[1].strip()

#print(json.dumps(Match, indent=4))
#print(Match)

# SQL queries

'''
Create table Match_Type(
matchTypeId Primary Key,
type varchar (50) not null unique
);
'''
#Match_Type Insert query
matchTypeID = 1
print(f"Insert into Match_Type(matchTypeID, type) Values({matchTypeID}, '{Match['matchType']}');")


'''
Create table Team(
teamID int Primary Key,
teamName varchar(100) not null unique
);

Create table Player(
playerID int Primary Key,
playerName varchar(100) not null,
teamID int not null references Team(teamID)
);
'''
#Team, Player Insert queries
teamID = 0
playerID = 0

for index, team in enumerate(Match["teams"]):#enumerate automatically handles both index(starting at 0) and value of list at the same time 
    teamID += 1
    print(f"Insert into Team (teamID, teamName) Values({teamID}, '{team['name']}');")
    for player in team["players"]:
        playerID += 1
        print(f"Insert into Player (playerID, playerName, teamID) Values({playerID}, '{player}', {teamID});")


'''
Create table Match(
matchID int Primary Key,
matchTypeID int not null references Match_Type(matchTypeId),
team1 int not null references Team(teamID),
team2 int not null references Team(teamID) Check(team1 != team2),
date Date not null,
venue varchar(100) not null,
matchResult varchar(100) not null,
matchWinner int references Team(teamID),
tossDecision varchar(100) not null,
tossWinner int not null references Team(teamID),
);

'''
#Match Insert query
#note:3 times double quotes is for multiline formated string span
if Match["tossWinner"] == Match["teams"][0]["name"]:
	tossWinner = 1
else:
	tossWinner = 2
if Match["matchWinner"] == Match["teams"][0]["name"]:
	matchWinner = 1
else:
	matchWinner = 2

print(f"""Insert into Match(matchID, matchTypeID, team1, team2, date, venue, matchResult, matchWinner, tossDecision, tossWinner) Values({Match['matchID']}, {matchTypeID}, 1, 2, '{Match['date']}', '{Match['venue']}', '{Match['matchResult']}', {matchWinner}, '{Match['tossDecision']}', {tossWinner});""")

'''
Create table Inning(
inningID Primary Key,
matchID int not null references Match(matchID),
inningNo int not null Check(inningNo in(1, 2)),
teamID int not null references Team(teamID),
runs int not null Check( runs >= 0)
);

Create table Match_Record(
matchRecordID Primary Key,
inningID int not null references Inning(inningID),
over int not null Check(over >= 0),
delivery int not null Check(delivery >=0),
striker int not null references Player(playerID),
nonStriker int not null references Player(playerID),
bowler int not null references Player(playerID) Check(striker != nonStriker != bowler),
strikerRuns int not null Check(strikerRuns >= 0),
extras int not null Check(extras >= 0),
total int not null Check(total = extras + strikerRuns)
);

'''

#Inning, Match_Record Insert queries
inningID = 0
matchRecordID = 0

for index, inning in enumerate(Match["inning"]):#enumerate automatically handles both index(starting at 0) and value of list at the same time 
    inningID += 1

    if inning["team"] == Match["teams"][0]["name"]:
        battingTeamID = 1
        bowlingTeamID = 2
    else:
        battingTeamID = 2
        bowlingTeamID = 1
   
    inningTotal = 0
    for over in inning["overs"]:
	    for delivery in over["deliveries"]:
		    runs = delivery.get("totalRuns")
		    if runs is not None:
			    inningTotal += int(runs)

    print(f"Insert into Inning(inningID, matchID, inningNo, teamID, runs) Values({inningID}, {Match['matchID']}, {index+1}, {battingTeamID}, {inningTotal});")

    playerID = None
    for over in inning["overs"]:
	    for delivery in over["deliveries"]:
		    matchRecordID += 1
		    teamOffset = 0 if battingTeamID == 1 else len(Match["teams"][0]["players"])
		    bowlingTeamOffset = 0 if bowlingTeamID == 1 else len(Match["teams"][0]["players"])

		    batsman = Match["teams"][battingTeamID-1]["players"].index(delivery["batsman"]) + 1 + teamOffset
		    nonStriker = Match["teams"][battingTeamID-1]["players"].index(delivery["nonStriker"]) + 1 + teamOffset

		    bowler = Match["teams"][bowlingTeamID-1]["players"].index(delivery["bowler"]) + 1 + bowlingTeamOffset

		    print(f"""Insert into Match_Record(matchRecordID, inningID, over, delivery, striker, nonStriker, bowler, strikerRuns, extras, total) Values({matchRecordID}, {inningID}, {over['overNo']}, {delivery['deliveryNo']}, '{batsman}', '{nonStriker}', '{bowler}',{delivery['batsmanRuns']}, {delivery['extrasRuns']}, {delivery['totalRuns']});""")

