package esp8266_at is
   
   type Esp_Mode is (STA, AP, BOTH);
   
   procedure Reset;
   
   procedure Wifi_Mode (mode : Esp_Mode);
   
   procedure AP_Join (ssid : String ; pswd : String);
   
   procedure Init;
   
   procedure AP_Quit;
   
   procedure AP_Param (param : String);
   
   type Connection_Type is (UDP, TCP);
   
   procedure Connect_Single (conType : Connection_Type; ip : String; port : String);
   
   procedure Write_Data_Single (data : String);
   
   procedure Disconnect_Single;
   
   type Mult is (Single, Multiple);
   
   procedure Multiple_conn (Var : Mult);
   
   procedure Read_Data_Single;
   
   procedure Send (This : String);

   function GetInMsg return String;

   procedure ClearInMsg;
end 
esp8266_at;
