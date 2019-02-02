with BMP_Fonts;
with Driver;               pragma Unreferenced (Driver);
with HAL.Bitmap;            use HAL.Bitmap;
with HAL.Framebuffer;       use HAL.Framebuffer;
with LCD_Std_Out;
with Last_Chance_Handler;  pragma Unreferenced (Last_Chance_Handler);
with STM32.Board;           use STM32.Board;
with System;

with IRC;
with esp8266_at;

procedure Main is
	pragma Priority (System.Priority'First);

	BG_Color : constant Bitmap_Color := (Alpha => 255, others => 64);

	-- Change according to your network
	Wifi_Name : Constant String := "wifi_name";
	Wifi_Pswd : Constant String := "pswd";

	procedure Clear_Screen is
	begin
	   LCD_Std_Out.Clear_Screen;
	   Display.Update_Layer (1, Copy_Back => True);
	end Clear_Screen;
begin
	-- ESP8266 network configuration
	esp8266_at.Init;
	esp8266_at.Reset;
	esp8266_at.Wifi_Mode(esp8266_at.STA);
	esp8266_at.AP_Join(Wifi_Name, Wifi_Pswd);
	esp8266_at.Multiple_conn(esp8266_at.Single);
	esp8266_at.Connect_Single(esp8266_at.TCP, "irc.rezosup.org", "6697");

	-- init LCD screen
	Display.Initialize;
	Display.Initialize_Layer (1, ARGB_8888);

	LCD_Std_Out.Set_Orientation (Landscape);
	LCD_Std_Out.Set_Font (BMP_Fonts.Font8x8);
	LCD_Std_Out.Current_Background_Color := BG_Color;

	Clear_Screen;

	-- IRC Registration
	IRC.NickIRC ("amy");
	IRC.UserIRC ("amy", "Amy Pond");
	IRC.ReceiveIRC;
	IRC.PrintLastIRCMessage;
	loop
	   null;
	end loop;
end Main;
