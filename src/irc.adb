with LCD_Console;
with esp8266_at;

package body IRC is
	-- IRC messages record
	-- Choose size with available memory in mind
	type IRCMessage (Size : Natural) is
		record
			prefix : String(1 .. Size) := (others => Character'Val (0));
			nickname : String(1 .. Size) := (others => Character'Val (0));
			username : String(1 .. Size) := (others => Character'Val (0));
			host : String(1 .. Size) := (others => Character'Val (0));
			channel : String(1 .. Size) := (others => Character'Val (0));
			command : String(1 .. Size) := (others => Character'Val (0));
			parameters : String(1 .. Size) := (others => Character'Val (0));
			text : String(1 .. Size):= (others => Character'Val (0));
		end record;
	IMsg : IRCMessage(255); -- the last IRC message received

	procedure Flush_IRC_Msg;

	procedure Parse_Raw_Data (Data : String);
	procedure Send_Cmd (Data : String);

	procedure Flush_IRC_Msg is
	begin
		IMsg.prefix := (others => Character'Val (0));
		IMsg.nickname := (others => Character'Val (0));
		IMsg.username := (others => Character'Val (0));
		IMsg.command := (others => Character'Val (0));
		IMsg.parameters  := (others => Character'Val (0));
		IMsg.text := (others => Character'Val (0));
	end Flush_IRC_Msg;

	procedure Set_Password (Pswd : String) is
	begin
		Send_Cmd ("PASS " & Pswd);
	end Set_Password
;

	procedure Set_Nickname (Nickname : String) is
	begin
		Send_Cmd ("NICK " & Nickname);
	end Set_Nickname;

	procedure Set_Username (Username : String; Fullname : String) is
	begin
		-- * * means unused parameter
		Send_Cmd ("USER " & Username & " * * :" & Fullname);
		-- TODO check this parameter...
	end Set_Username;

	procedure Parse_Raw_Data (Data : String) is
		cursor1 : Natural := 1;
		cursor2 : Natural := 1;
	begin
		-- Prefix parsing (optional)
		if (Data (Data'First) = ':') then
			for I in Data'Range loop
				if Data (I) = ' ' then
					cursor1 := I;
				end if;
			end loop;

			IMsg.prefix(1 .. cursor1) := Data (Data'First .. cursor1);

			for I in Data'Range loop
				if Data (I) = '@' then
					cursor2 := I;
				end if;
			end loop;

			if cursor2 /= IMsg.prefix'Last then -- TODO test this
				IMsg.nickname (1 .. cursor2) := IMsg.prefix (1 .. cursor2);
				IMsg.host (1 .. cursor1 - cursor2) := IMsg.prefix(cursor2 .. cursor1);
			end if;

			cursor1 := cursor1 + 1; -- get rid of blank
		end if;

		-- Command parsing
		for I in cursor1 .. Data'Last loop
			if Data (I) = ' ' then
				cursor2 := I;
			end if;
		end loop;

		IMsg.command (1 .. cursor2 - cursor1) := Data (cursor1 .. cursor2);

		-- Text parsing
		cursor1 := cursor2 + 1;

		if (cursor2 < Data'Last) then
			if (Data (cursor2) = ':') then
				IMsg.text (1 .. Data'Last - cursor2) := Data (cursor2 .. Data'Last);
			else
				for J in cursor2 .. Data'Last loop
					if (Data (J) = ':') then
						IMsg.parameters (1 .. J - cursor2) := Data (cursor2 .. J);
						IMsg.text (1 .. Data'Last - cursor2) := Data (J .. Data'Last);
					end if;
				end loop;
			end if;
		end if;
	end Parse_Raw_Data;

	procedure Send_Cmd (Data : String) is
	begin
		esp8266_at.Send (Data & "\r\n");
	end Send_Cmd;

	procedure Connect_To_Server (Server_Addr : String; Channel : String) is
	begin
		esp8266_at.Connect_Single(esp8266_at.TCP,
					  Server_Addr, "194");
		Send_Cmd ("JOIN " & Channel);
	end Connect_To_Server;

	procedure Send_Msg (Recipient : String; Data : String) is
	begin
		Send_Cmd ("PRIVMSG " & Recipient & " :" & Data);
	end Send_Msg;

	procedure Receive_Msg is
	begin
		Flush_IRC_Msg;
		esp8266_at.ClearInMsg;
		esp8266_at.Read_Data_Single;
		delay (0.5); -- wait for buffer to fill
		if (esp8266_at.GetInMsg (1 .. 4) = "+IPD") then
			for I in esp8266_at.GetInMsg'Range loop
				if (esp8266_at.GetInMsg (I) = ':') then
					Parse_Raw_Data (esp8266_at.GetInMsg (4 .. esp8266_at.GetInMsg'Last));
				end if;
			end loop;
		end if;
	end Receive_Msg;

	procedure Print_Last_IRC_Msg is
	begin
	   LCD_Console.Put_Line(IMsg.prefix & IMsg.Nickname
				  & "<" & Imsg.username & "@" & Imsg.host & ">"
				  & " /" & Imsg.command & Imsg.parameters);
	   LCD_Console.Put_Line(Imsg.text);
	end Print_Last_IRC_Msg;
end IRC;
