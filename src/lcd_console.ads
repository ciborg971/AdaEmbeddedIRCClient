with Ada.Containers.Vectors;
with BMP_Fonts;     use BMP_Fonts;
with HAL.Bitmap;

-- LCD_Console : provide a way to output data on the STM32F429 screen.
--
-- This package is similar to LCD_Std_Out.
-- Compared to LCD_Std_Out, with LCD_Console the screen is automatically
-- scrolled when it is full.
package LCD_Console is
   Text_Color       : constant HAL.Bitmap.Bitmap_Color := HAL.Bitmap.White;
   Background_Color : constant HAL.Bitmap.Bitmap_Color := HAL.Bitmap.Black;
   Font             : constant BMP_Font := Font8x8;

   package Character_Vectors is new Ada.Containers.Vectors
     (Index_Type   => Natural,
      Element_Type => Character);
   use Character_Vectors;

   procedure Init;

   procedure Clear_Screen;
   procedure Flush;

   procedure Put (Msg : Character);
   procedure Put (Msg : String);
   procedure Put_Line (Msg : String);

   function Console_Buffer_Is_Shifted (New_Buffer : Vector; Old_Buffer : Vector)
				      return Boolean;
   procedure New_Line
     with Post => (
	Cur_Line + 1 < Console_Buffer_Height or else
		Console_Buffer_Is_Shifted (Console_Buffer, Console_Buffer'Old)
	);

   -- internal definitions
   Console_Buffer : Vector;

   -- current position in the Console_Buffer
   Cur_Line : Natural := 0;
   Cur_Col : Natural := 0;

   Console_Buffer_Width : Natural;
   Console_Buffer_Height : Natural;
end LCD_Console;
