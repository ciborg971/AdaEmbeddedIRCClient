package IRC is
	-- IRC messages record
	-- Choose size with available memory in mind
	type IRCMessage (Size : Natural) is
		record
			prefix : String(1 .. Size) := (others => Character'Val (0));
			nickname : String(1 .. Size) := (others => Character'Val (0));
			username : String(1 .. Size) := (others => Character'Val (0));
			host : String(1 .. Size) := (others => Character'Val (0));
			command : String(1 .. Size) := (others => Character'Val (0));
			parameters : String(1 .. Size) := (others => Character'Val (0));
			text : String(1 .. Size):= (others => Character'Val (0));
		end record;

	IMsg : IRCMessage(255);

	procedure SendIRC (Data : String);
	procedure SendMsg (Recipient : String; Data : String);

	procedure PswdIRC (pswd : String);
	procedure NickIRC (nickname : String);
	procedure UserIRC (username : String; fullname : String);
	procedure ParseIRC (Data : String);

	procedure FlushIRCMessage;
	procedure ReceiveIRC;

	procedure PrintLastIRCMessage;
end IRC;
