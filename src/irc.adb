with LCD_Std_Out;
with esp8266_at;

package body IRC is
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
	end ParseIRC;

	procedure FlushIRCMessage is
	begin
		IMsg.prefix := (others => Character'Val (0));
		IMsg.nickname := (others => Character'Val (0));
		IMsg.username := (others => Character'Val (0));
		IMsg.host := (others => Character'Val (0));
		IMsg.command := (others => Character'Val (0));
		IMsg.parameters  := (others => Character'Val (0));
		IMsg.text := (others => Character'Val (0));
	end flushIRCMessage;

	procedure ReceiveIRC is
	begin
		FlushIRCMessage;
		esp8266_at.ClearInMsg;
		esp8266_at.Read_Data_Single;
		delay(0.5); -- wait for buffer to fill
		if (esp8266_at.GetInMsg (1 .. 4) = "+IPD") then
			for I in esp8266_at.GetInMsg'Range loop
				if (esp8266_at.GetInMsg (I) = ':') then
					ParseIRC(esp8266_at.GetInMsg (4 .. esp8266_at.GetInMsg'Last));
				end if;
			end loop;
		end if;
	end ReceiveIRC;

	procedure PrintLastIRCMessage is
	begin
	   LCD_Std_Out.Put_Line(IMsg.prefix & IMsg.Nickname
				  & "<" & Imsg.username & "@" & Imsg.host & ">"
				  & " /" & Imsg.command & Imsg.parameters);
	   LCD_Std_Out.Put_Line(Imsg.text);
	end PrintLastIRCMessage;
end IRC;
