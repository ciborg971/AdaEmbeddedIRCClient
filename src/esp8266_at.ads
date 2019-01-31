package esp8266_at is
   
   type Esp_Mode is (STA, AP, BOTH);
   
   procedure Reset;
   
   procedure Wifi_Mode (mode : Esp_Mode);
   
   procedure AP_Join (ssid : String ; pswd : String)
	   with 
	   Pre => ssid'Length + pswd'Length + 12 <= 1024;
   
   procedure Init;
   
   procedure AP_Quit;
   
   procedure AP_Param (param : String)
	   with
	   Pre => param'Length + 11 <= 1024;
   
   type Connection_Type is (UDP, TCP);
   
   procedure Connect_Single (conType : Connection_Type; ip : String; port : String)
	   with
	   Pre => 17 + ip'Length + port'Length <= 1024;
   
   procedure Write_Data_Single (data : String)
	   with
	   Pre => 13 + Integer'Image(data'Length)'Length <= 1024 and data'Length + 2 <= 1024;
   
   procedure Disconnect_Single;
   
   type Mult is (Single, Multiple);
   
   procedure Multiple_conn (Var : Mult);
   
   procedure Read_Data_Single;
   
   procedure Send (This : String)
	   with
	   Pre => This'Length <= 1024;

   function GetInMsg return String;

   procedure ClearInMsg;
end 
esp8266_at;
