package IRC is
	procedure Connect_To_Server (Server_Addr : String; Channel : String);
	procedure Send_Msg (Recipient : String; Data : String);
	procedure Receive_Msg;

	procedure Set_Nickname (Nickname : String);
	procedure Set_Username (Username : String; Fullname : String);
	procedure Set_Password (Pswd : String);

	procedure Print_Last_IRC_Msg;
end IRC;
