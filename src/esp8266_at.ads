package esp8266_at is
   
   type Esp_Mode is (STA, AP, BOTH);
   
   procedure Reset;
   
   function Wifi_Mode (mode : Esp_Mode) return Boolean;
   
   procedure AP_Join (ssid : String ; pswd : String);
   
   procedure Init;
   
   function AP_Quit return Boolean;
   
   function AP_Param (param : String) return Boolean;
   
   type Connection_Type is (UDP, TCP);
   
   function Connect_Single (conType : Connection_Type; ip : String; port : String) return Boolean;
   
   function Write_Data_Single (data : String) return Boolean;
   
   procedure Disconnect_Single;
   
   type Mult is (Single, Multiple);
   
   function Multiple_conn (Var : Mult) return Boolean;
   
   procedure Read_Data_Single;
   
   procedure Send (This : String);
end 
esp8266_at;
