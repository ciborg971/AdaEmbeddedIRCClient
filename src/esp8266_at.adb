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
		Send ("AT+RST");
	end Reset;

	function Wifi_Mode (mode : Esp_Mode) return Boolean is
		Var : Constant String := "AT+CWMODE=";
	begin
		case mode is
			when STA =>
				Send (Var & "1");
			when AP =>
				Send (Var & "2");
			when others =>
				Send (Var & "3");
		end case;
		return True;
	end Wifi_Mode;

	procedure AP_Join (ssid : String; pswd : String) is
	begin
		Send ("AT+CWJAP=" & ssid & "," & pswd);
	end AP_Join;

	procedure Init is 
	begin
		Initialize (COM);
		Configure (COM, Baud_Rate => 9_600); -- Can 115_200 on some board
	end Init;

	function AP_Quit return Boolean is 
	begin
		Send ("AT+CWQAP");
		return True;
	end AP_Quit;

	function AP_Param (param : String) return Boolean is
	begin
		Send ("AT+CWSAP=" & param);
		return True;
	end AP_Param;

	function Connect_Single (conType : Connection_Type; ip : String; port : String) return Boolean is
		Var : Constant String := "AT+CIPSTART="; 
	begin
		if conType = UDP then
			Send (Var & "UDP" & "," & ip & "," & port);
		else
			Send (Var & "TCP" & "," & ip & "," & port);
		end if;
		return True;
	end Connect_Single;

	function Write_Data_Single (data : String) return Boolean is
	begin
		return True;
	end Write_Data_Single;

	procedure Disconnect_Single is
	begin
		Send ("AT+CIPCLOSE");
	end Disconnect_Single;

	function Multiple_conn (Var : Mult) return Boolean is
	begin
		if Var = Single then
			Send ("AT+CIPMUX=0");
		else
			Send ("AT+CIPMUX=1");
		end if;
		return True;
	end Multiple_conn;

	procedure Read_Data_Single is
	begin
		Get (COM, Incoming'Unchecked_Access);
	end Read_Data_Single;
end esp8266_at;
