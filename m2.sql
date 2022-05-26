DROP DATABASE IF EXISTS WarlockGame;
CREATE DATABASE WarlockGame;
USE WarlockGame;

DROP USER if exists 'warlock'@'localhost';

CREATE USER 'warlock'@'localhost' IDENTIFIED BY '12345';
GRANT ALL ON WarlockGame.* TO 'warlock'@'localhost';

DROP PROCEDURE IF EXISTS makeDatabase;
DELIMITER //
CREATE PROCEDURE makeDatabase()
BEGIN
	DROP TABLE IF EXISTS tblPlayer;
	CREATE TABLE tblPlayer(
		playerID INTEGER NOT NULL PRIMARY KEY auto_increment,
		username varchar (50) unique not null, 
		email varchar (50),
		playerPassword varchar (50),
		isAdmin boolean default false,
		attempts INT DEFAULT 0
	);
	
    INSERT INTO tblPlayer (username, email, playerPassword, isAdmin)
    VALUES 
		('Dave', 'dave@hotmail.com', 'hello123', false),
		('Todd', 'tod@nmit.com', 'helo123', true),
        ('Hacker', 'noemail@hotmail.com', 'badie', false);
        
	UPDATE tblPlayer 
    SET username = 'rowe', email = 'rowe@hotmail.com'
    WHERE playerID = 1;
    DELETE FROM tblPlayer WHERE username='Todd';
    
    
	CREATE TABLE tblMapTile(
		tileID INTEGER NOT NULL PRIMARY KEY,
		tileRow INT NOT NULL,
		tileColumn INT NOT NULL,
		tileStatus varchar (50)
	);

  INSERT INTO tblMapTile (tileID, tileRow, tileColumn, tileStatus)
    VALUES 
		(1, 1, 1, 'item'),
		(2, 1, 2, 'item'),
        (3, 1, 3, 'empty'),
        (4, 1, 4, 'monster'),
        (5, 2, 1, 'empty');
	UPDATE tblMapTile 
    SET tileStatus = 'player'
    WHERE tileID = 1;
    DELETE FROM tblMapTile WHERE tileColumn=3;
    
    
	CREATE TABLE tblMap(
		mapID INTEGER NOT NULL PRIMARY KEY,
		tileID int, 
		FOREIGN KEY (tileID) REFERENCES tblMapTile(tileID)
	); 
    
	INSERT INTO tblMap (mapID, tileID)
    VALUES 
		(1, 1),
        (2, 2);

	UPDATE tblMap 
    SET tileID = 2
    WHERE tileID = 1;
    DELETE FROM tblMap WHERE mapID=1;
    

	CREATE TABLE tblCharacter(
		characterID INTEGER NOT NULL PRIMARY KEY auto_increment,
		characterType varchar (50),
		score int default 0,
		color varchar (50),
		magic int,
		strength int,
		fate int default 4,
		playerID int,
        TileID int,
        FOREIGN KEY (tileID) REFERENCES tblMapTile(tileID),
		FOREIGN KEY (playerID) REFERENCES tblPlayer(playerID)
	);
    
	INSERT INTO tblCharacter(characterType, score, color, magic, strength, fate, playerID)
    VALUES 
		('fel', 1337, 'blue', 5, 4, 3, 1),
		('hexed', 0, 'red', 4, 5, 3, 3);
    UPDATE tblCharacter
    SET magic = 9
    WHERE characterID = 1;
    DELETE FROM tblCharacter WHERE playerID=3;


	CREATE TABLE tblMonster(
		monsterID INTEGER NOT NULL PRIMARY KEY,
		monsterType varchar(50),
		magic int,
		strength int, 
		fate int, 
		tileID int,
		FOREIGN KEY (tileID) REFERENCES tblMapTile(tileID)
	);
    
	INSERT INTO tblMonster(monsterID, monsterType, magic, strength, fate, tileID)
    VALUES 
		(1, 'spirit',8, 4, 2, 5),
		(2, 'demon', 5, 9, 2, 4);
    UPDATE tblMonster
    SET monsterType = 'greaterDemon'
    WHERE monsterID = 2;
    DELETE FROM tblMonster WHERE tileID=5;


	CREATE TABLE tblObject(
		objectID INTEGER NOT NULL PRIMARy KEY,
		objectType varchar (50),
		tileID int,
		FOREIGN KEY (tileID) REFERENCES tblMapTile(tileID)
	);
    
	INSERT INTO tblObject(objectID, objectType, tileID)
    VALUES 
		(1, 'magicItem', 2),
		(2, 'StrengthItem', 1);
    UPDATE tblObject
    SET objectType = 'fateItem'
    WHERE objectID = 2;
    DELETE FROM tblObject WHERE tileID=2;

	CREATE TABLE tblSession(
		sessionID INTEGER NOT NULL PRIMARY KEY,
		highScore int,
		playerID int,
		FOREIGN KEY (playerID) REFERENCES tblPlayer(playerID)
	);
    
    INSERT INTO tblSession(sessionID, highScore, playerID)
    VALUES 
		(1, 1337, 1),
        (2, 0, 3);
        UPDATE tblSession
        SET highscore = 5000
        WHERE SessionID = 1;
        DELETE FROM tblSession WHERE sessionID = 2;

END//
DELIMITER ;
CALL Warlockgame.makeDatabase();


DELIMITER $$

Drop procedure if exists Register$$
Create procedure Register( in pUserName VARCHAR(50), IN pPassword VARCHAR(50), IN pEmail VARCHAR(50) )
COMMENT 'Register User'
BEGIN
INSERT INTO tblPlayer(username, playerPassword, email)
    Values (pUsername, pPassword, pEmail);    
END $$

DELIMITER ;

DELIMITER $$

DROP PROCEDURE IF EXISTS Login$$
CREATE PROCEDURE Login( IN pUserName VARCHAR(50), IN pPassword  VARCHAR(50))
COMMENT 'Check login'
BEGIN
    DECLARE numAttempts INT DEFAULT 0;
    
	-- 'Check for valid login', 
    -- if valid then select message "Logged in" and reset Attempts to 0, 
    IF EXISTS ( SELECT * 
                FROM tblPlayer
                WHERE 
                  userName = pUserName AND
                  playerPassword = pPassword 
                  ) 
	THEN
		UPDATE tblPlayer 
        SET Attempts = 0
        WHERE
           userName = pUserName;
           
		SELECT 'Logged In' as Message;
    
    ELSE 
    -- else add to Attempts ,
        IF EXISTS(SELECT * FROM tblPlayer WHERE UserName = pUserName) THEN 
        
			SELECT Attempts 
			INTO numAttempts
			FROM tblPlayer
			WHERE 
			   userName = pUserName;
			
			SET numAttempts = numAttempts + 1;
			
			IF numAttempts > 5 THEN 
			-- if Attempts > 5 then set lockout  to true and select message 'locked out' 
				UPDATE tblPlayer 
				SET LOCKED_OUT = True
				WHERE 
					 userName = pUserName ;
					 
				 SELECT 'Locked Out' AS Message;
				 
			ELSE
			-- else select message 'Bad  password'
                 UPDATE tblPlayer
                 SET Attempts = numAttempts
                 WHERE 
                    userName = pUserName;
                    
				 SELECT 'Invalid user name and password';
			END IF;
      ELSE 
		SELECT 'Invalid user name and password';
      END IF;

    
    END IF;
                  
END $$

DELIMITER ;

DELIMITER $$

DROP PROCEDURE IF EXISTS CreateCharacter$$
CREATE PROCEDURE CreateCharacter(pUsername varchar(50), pCharacterType varChar(50), pColor VarChar(50), pMagic int, pStrength int, pTileID int)
COMMENT 'Create Character'
BEGIN
INSERT INTO tblCharacter(characterType, color, magic, strength, TileID, playerID)
    Values (pCharacterType, pColor, pMagic, pStrength, pTileID, (SELECT PlayerID from tblPlayer WHERE username = pUsername));

END $$

DELIMITER ;

-- DELIMITER $$

-- drop procedure if exists addScore$$
-- create procedure addScore(pUsername varchar(50))
-- comment 'increase score'
-- begin
-- select * from tblPlayer 
-- where username = pUsername

-- set score = score + 50;
-- end $$

-- DELIMITER ;

DELIMITER $$

drop procedure if exists characterSpawn$$
create procedure characterSpawn(pCharacterID int)
comment 'Spawn Character'
begin
	select * from tblCharacter;
    update tblCharacter
    set tileID = rand(1-5)
    Where characterID = pCharacterID;
end$$

DELIMITER ;

DELIMITER $$

drop procedure if exists objectSpawn$$
create procedure characterSpawn(pObjectID int, pObjectType varchar(50))
comment 'Spawn item'
begin
	select * from tblObject;
    update tblCharacter
    set objectType = rand('health', 'strength', 'portal'),
		tileID = rand(1-5);
    Where characterID = pCharacterID;
end$$

DELIMITER ;




-- call CreateCharacter('rowe', 'hexed', 'Red', 100, 150, 5);
select * from tblCharacter;

-- call Register('Peter', '12345', 'peter@email.com');
select * from tblPlayer;

-- call increaseScore('rowe');

call characterSpawn(1)





