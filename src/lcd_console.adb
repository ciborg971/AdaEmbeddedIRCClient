with Ada.Containers.Vectors;
with Bitmap_Color_Conversion; use Bitmap_Color_Conversion;
with Bitmapped_Drawing;
with HAL.Bitmap;            use HAL.Bitmap;
with HAL.Framebuffer;
with STM32.Board; use STM32.Board;

package body LCD_Console is
   Char_Width  : Natural;
   Char_Height : Natural;

   Console_Buffer_Width : Natural;
   Console_Buffer_Height : Natural;

   package Character_Vectors is new Ada.Containers.Vectors
     (Index_Type   => Natural,
      Element_Type => Character);
   use Character_Vectors;

   Console_Buffer : Vector;

   -- current position in the Console_Buffer
   Cur_Line : Natural := 0;
   Cur_Col : Natural := 0;

   procedure Draw_Char (X, Y : Natural; Msg : Character);
   procedure Internal_Put (Msg : Character);
   procedure Internal_Put (Msg : String);
   procedure Scroll_Down_One_Line;

   procedure Init is
   begin
      Char_Width := BMP_Fonts.Char_Width (Font);
      -- increase the height of a character so that the characters are
      -- rendered with more space between them.
      Char_Height := BMP_Fonts.Char_Height (Font) + 2;

      -- since the screen will be flipped (landscape mode; see below),
      -- the width and height should be inverted here...
      Console_Buffer_Width := LCD_Natural_Height / Char_Width;
      Console_Buffer_Height := LCD_Natural_Width / Char_Height;

      for I in 0 .. (Console_Buffer_Width * Console_Buffer_Height - 1) loop
	 Console_Buffer.Append (' ');
      end loop;

      Display.Initialize (Mode => HAL.Framebuffer.Polling);
      Display.Initialize_Layer (1, HAL.Bitmap.RGB_565);

      Display.Set_Orientation (HAL.Framebuffer.Landscape);
      Clear_Screen;
   end Init;

   procedure Clear_Screen is
   begin
      for E of Console_Buffer loop
	 E := ' ';
      end loop;

      Display.Hidden_Buffer (1).Set_Source (Background_Color);
      Display.Hidden_Buffer (1).Fill;
      Flush;

      Cur_Line := 0;
      Cur_Col := 0;
   end Clear_Screen;

   procedure Flush is
   begin
      Display.Update_Layer (1, Copy_Back => True);
   end Flush;

   procedure Put (Msg : String) is
   begin
      Internal_Put (Msg);
   end Put;

   procedure Draw_Char (X, Y : Natural; Msg : Character) is
   begin
      Bitmapped_Drawing.Draw_Char
        (Display.Hidden_Buffer (1).all,
         Start      => (X, Y),
         Char       => Msg,
         Font       => Font,
         Foreground =>
           Bitmap_Color_To_Word (Display.Color_Mode (1), Text_Color),
         Background =>
           Bitmap_Color_To_Word (Display.Color_Mode (1),
             Background_Color));
   end Draw_Char;

   procedure Internal_Put (Msg : String) is
   begin
      for C of Msg loop
            Internal_Put (C);
      end loop;
   end Internal_Put;

   procedure Internal_Put (Msg : Character) is
      Y, X : Natural;
   begin
      if Msg = ASCII.LF then
	 New_Line;
	 return;
      end if;

      Console_Buffer (Cur_Line * Console_Buffer_Width + Cur_Col) := Msg;

      Y := Cur_Line * Char_Height;
      X := Cur_Col * Char_Width;
      Draw_Char (X, Y, Msg);

      if Cur_Col + 1 >= Console_Buffer_Width then
	 New_Line;
      else
	 Cur_Col := Cur_Col + 1;
      end if;
   end Internal_Put;

   -- shifts all the data printed on the screen one line up
   procedure Scroll_Down_One_Line is
      Y, X : Natural;
      Buffer_Width : constant Ada.Containers.Count_Type :=
	Ada.Containers.Count_Type(Console_Buffer_Width);
   begin
      Console_Buffer.Delete_First(Count => Buffer_Width);

      Console_Buffer.Append(' ', Count => Buffer_Width);

      for L in 0 .. (Console_Buffer_Height - 1) loop
      	 for C in 0 .. (Console_Buffer_Width - 1) loop
      	    Y := L * Char_Height;
      	    X := C * Char_Width;

      	    Draw_Char (X, Y, Console_Buffer (L * Console_Buffer_Width + C));
      	 end loop;
      end loop;

      Cur_Line := Cur_Line - 1;
   end Scroll_Down_One_Line;

   procedure Put (Msg : Character) is
   begin
      Internal_Put (Msg);
   end Put;

   procedure Put_Line (Msg : String) is
   begin
      Put (Msg);
      -- XXX, what happens if the cursor is at the end of a line ?
      New_Line;
   end Put_Line;

   procedure New_Line is
   begin
      if Cur_Line + 1 >= Console_Buffer_Height then
      	 Scroll_Down_One_Line;
      end if;

      Cur_Line := Cur_Line + 1;
      Cur_Col := 0;
   end New_Line;
end LCD_Console;
