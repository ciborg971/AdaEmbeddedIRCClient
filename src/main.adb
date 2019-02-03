with Driver;               pragma Unreferenced (Driver);
with Last_Chance_Handler;  pragma Unreferenced (Last_Chance_Handler);
with System;

with IRC;
with LCD_Console;
with esp8266_at;

procedure Main is
	pragma Priority (System.Priority'First);

	-- Change according to your network
	Wifi_Name : Constant String := "wifi_name";
	Wifi_Pswd : Constant String := "pswd";
begin
	-- ESP8266 network configuration
	esp8266_at.Init;
	esp8266_at.Reset;
	esp8266_at.Wifi_Mode(esp8266_at.STA);
	esp8266_at.AP_Join(Wifi_Name, Wifi_Pswd);
	esp8266_at.Multiple_conn(esp8266_at.Single);

	LCD_Console.Init;

	-- IRC Registration
	IRC.Connect_To_Server ("irc.rezosup.org", "6667", "test");
	IRC.Set_Nickname ("test_bot");
	IRC.Set_Username ("test_bot", "Test Bot");

	loop
	   IRC.Receive_Msg;
	   IRC.Print_Last_IRC_Msg;
	   LCD_Console.Flush;
	end loop;
end Main;
