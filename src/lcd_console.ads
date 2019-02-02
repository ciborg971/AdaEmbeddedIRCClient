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

   procedure Init;

   procedure Clear_Screen;
   procedure Flush;

   procedure Put (Msg : Character);
   procedure Put (Msg : String);
   procedure Put_Line (Msg : String);
   procedure New_Line;
end LCD_Console;
