with Peripherals_Blocking;  use Peripherals_Blocking;
with Serial_IO.Blocking;    use Serial_IO.Blocking;
with Message_Buffers; 	    use Message_Buffers;

use Serial_IO;

package body esp8266_at is


	Incoming : aliased Message (Physical_Size => 1024);
	Outgoing : aliased Message (Physical_Size => 1024);

	procedure Send (This : String) is
	begin
		Set (Outgoing, To => This);
		Blocking.Put (COM, Outgoing'Unchecked_Access);
	end Send;

	procedure Reset is 
	begin
		Send ("AT+RST\r\n");
	end Reset;

	procedure Wifi_Mode (mode : Esp_Mode) is
		Var : Constant String := "AT+CWMODE=";
	begin
		case mode is
			when STA =>
				Send (Var & "1\r\n");
			when AP =>
				Send (Var & "2\r\n");
			when others =>
				Send (Var & "3\r\n");
		end case;
	end Wifi_Mode;

	procedure AP_Join (ssid : String; pswd : String) is
	begin
		Send ("AT+CWJAP=" & ssid & "," & pswd & "\r\n");
	end AP_Join;

	procedure Init is 
	begin
		Initialize (COM);
		Configure (COM, Baud_Rate => 9_600); -- Can 115_200 on some board
	end Init;

	procedure AP_Quit is 
	begin
		Send ("AT+CWQAP" & "\r\n");
	end AP_Quit;

	procedure AP_Param (param : String) is
	begin
		Send ("AT+CWSAP=" & param & "\r\n");
	end AP_Param;

	procedure Connect_Single (conType : Connection_Type; ip : String; port : String) is
		Var : Constant String := "AT+CIPSTART="; 
	begin
		if conType = UDP then
			Send (Var & "UDP" & "," & ip & "," & port & "\r\n");
		else
			Send (Var & "TCP" & "," & ip & "," & port & "\r\n");
		end if;
	end Connect_Single;

	procedure Write_Data_Single (data : String) is
	begin
		Send ("AT+CIPSEND=" & Integer'Image(data'Length) & "\r\n");
		Send (data & "\r\n");
	end Write_Data_Single;

	procedure Disconnect_Single is
	begin
		Send ("AT+CIPCLOSE\r\n");
	end Disconnect_Single;

	procedure Multiple_conn (Var : Mult) is
	begin
		if Var = Single then
			Send ("AT+CIPMUX=0\r\n");
		else
			Send ("AT+CIPMUX=1\r\n");
		end if;
	end Multiple_conn;

	procedure Read_Data_Single is
	begin
		Get (COM, Incoming'Unchecked_Access);
	end Read_Data_Single;

	function GetInMsg return String is
	begin
		return Incoming.Content;
	end GetInMsg;

	procedure ClearInMsg is
	begin
		Incoming.Clear;
	end ClearInMsg;

end esp8266_at;
