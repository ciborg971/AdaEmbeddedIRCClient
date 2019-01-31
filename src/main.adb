------------------------------------------------------------------------------
--                                                                          --
--                             GNAT EXAMPLE                                 --
--                                                                          --
--             Copyright (C) 2014, Free Software Foundation, Inc.           --
--                                                                          --
-- GNAT is free software;  you can  redistribute it  and/or modify it under --
-- terms of the  GNU General Public License as published  by the Free Soft- --
-- ware  Foundation;  either version 3,  or (at your option) any later ver- --
-- sion.  GNAT is distributed in the hope that it will be useful, but WITH- --
-- OUT ANY WARRANTY;  without even the  implied warranty of MERCHANTABILITY --
-- or FITNESS FOR A PARTICULAR PURPOSE.                                     --
--                                                                          --
--                                                                          --
--                                                                          --
--                                                                          --
--                                                                          --
-- You should have received a copy of the GNU General Public License and    --
-- a copy of the GCC Runtime Library Exception along with this program;     --
-- see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see    --
-- <http://www.gnu.org/licenses/>.                                          --
--                                                                          --
-- GNAT was originally developed  by the GNAT team at  New York University. --
-- Extensive contributions were provided by Ada Core Technologies Inc.      --
--                                                                          --
------------------------------------------------------------------------------

--  The file declares the main procedure for the demonstration.

with Driver;               pragma Unreferenced (Driver);
--  The Driver package contains the task that actually controls the app so
--  although it is not referenced directly in the main procedure, we need it
--  in the closure of the context clauses so that it will be included in the
--  executable.

with Last_Chance_Handler;  pragma Unreferenced (Last_Chance_Handler);
--  The "last chance handler" is the user-defined routine that is called when
--  an exception is propagated. We need it in the executable, therefore it
--  must be somewhere in the closure of the context clauses.

with esp8266_at;

with System;

procedure Main is
	pragma Priority (System.Priority'First);

	-- Change according to your network 
	Wifi_Name : Constant String := "wifi_name";
	Wifi_Pswd : Constant String := "pswd";

	-- IRC messages record
	-- Choose size with available memory in mind
	type IRCMessage (Size : Natural) is 
		record
			prefix : String(1 .. Size);
			nickname : String(1 .. Size);
			username : String(1 .. Size);
			host : String(1 .. Size);
			command : String(1 .. Size);
			parameters : String(1 .. Size);
			test : String(1 .. Size);
		end record:

	IMsg : IRCMessage(1024) := 
		(prefix => (others => ' '),
		(nickname  => (others => ' '),
		(username  => (others => ' '),
		(host  => (others => ' '),
		(command  => (others => ' '),
		(parameters  => (others => ' '),
		(test  => (others => ' '));

	-- IRC related function
	procedure SendIRC (Data : String) is
	begin
		esp8266_at.Send (Data & "\r\n");
	end SendIRC;

	procedure SendMsg (Recipient : String; Data : String) is
	begin
		SendIRC ("PRIVMSG " & Recipient & " :" & Data);
	end SendMsg;

	procedure PswdIRC (pswd : String) is
	begin
		SendIRC ("PASS " & pswd);
	end PswdIRC;

	procedure NickIRC (nickname : String) is
	begin
		SendIRC ("NICK " & nickname);
	end NickIRC;

	procedure UserIRC (username : String; fullname : String) is
	begin
		SendIRC ("USER " & username & " * * :" & fullname); -- * * means unused parameter
		-- TODO check this parameter...
	end UserIRC;

	procedure ParseIRC (Data : String) is
		cursor1 : Natural := 0;
		cursor2 : Natural := 0;
	begin
		-- Prefix parsing (optional)
		if (Data'First = ':') then
			Search_Blank_Loop :
			for cursor1 in Data'Range loop
				exit Search_Blank_Loop when Data (cursor1) = ' ';
			end loop;
			IMsg.prefix(1 .. cursor1) := Data (1 .. cursor1);

			Search_At_Loop :
			for cursor2 in IMsg.prefix'Range loop
				exit Search_Blank_Loop when IMsg.prefix (cursor2) = '@';
			end loop;
			
			if cursor2 /= IMsg.prefix'Last then -- TODO test this
				IMsg.nick (1 .. cursor2) := IMsg.prefix (1 .. cursor2);
				IMsg.host (1 .. cursor1 - cursor2) := IMsg.prefix(cursor2 .. cursor1);
			end if;

			cursor1 := cursor1 + 1; -- get rid of blank
		end if;



	end ParseIRC;
begin
	-- ESP8266 network configuration
	esp8266_at.Init;
	esp8266_at.Reset;
	esp8266_at.Wifi_Mode(esp8266_at.STA);
	esp8266_at.AP_Join(Wifi_Name, Wifi_Pswd);
	esp8266_at.Multiple_conn(esp8266_at.Single);
	esp8266_at.Connect_Single(esp8266_at.TCP, "irc.rezosup.org", "6697");

	-- IRC Registration
	NickIRC ("amy");
	UserIRC ("amy", "Amy Pond");

	loop
		null;
	end loop;
end Main;
