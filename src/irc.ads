package IRC is
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
