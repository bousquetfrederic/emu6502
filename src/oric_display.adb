with Ada.Streams.Stream_IO;
with Data_Types;

package body Oric_Display is

   --  Oric memory the ULA scans (all plain RAM on a real Oric).
   Screen_Base : constant := 16#BB80#;
   Charset_Std : constant := 16#B400#;
   Charset_Alt : constant := 16#B800#;

   Columns : constant := 40;
   Rows    : constant := 28;
   Cell_W  : constant := 6;
   Cell_H  : constant := 8;

   type RGB is record
      R, G, B : Natural range 0 .. 255;
   end record;

   --  Canonical 3-bit Oric palette.
   Palette : constant array (Color_Index) of RGB :=
     (0 => (0,   0,   0),     --  black
      1 => (255, 0,   0),     --  red
      2 => (0,   255, 0),     --  green
      3 => (255, 255, 0),     --  yellow
      4 => (0,   0,   255),   --  blue
      5 => (255, 0,   255),   --  magenta
      6 => (0,   255, 255),   --  cyan
      7 => (255, 255, 255));  --  white

   procedure Render
     (Bus   :     Data_Bus.T_Data_Bus;
      Frame :     Natural;
      Fb    : out Framebuffer)
   is
      Flash_On : constant Boolean := (Frame / 16) mod 2 = 1;

      --  Read one RAM byte through the bus as a plain integer so
      --  none of Data_Types' custom operators are needed here.
      function Read (A : Integer) return Natural is
        (Natural (Data_Bus.Read_Byte (Bus, Data_Types.T_Address (A))));
   begin
      for Row in 0 .. Rows - 1 loop
         for Line in 0 .. Cell_H - 1 loop

            --  Serial attributes reset at the start of every line.
            declare
               Ink   : Color_Index := 7;   --  white
               Paper : Color_Index := 0;   --  black
               Alt   : Boolean := False;
               Dbl   : Boolean := False;
               Blink : Boolean := False;
            begin
               for Col in 0 .. Columns - 1 loop
                  declare
                     B  : constant Natural :=
                       Read (Screen_Base + Row * Columns + Col);
                     Px : constant Natural := Col * Cell_W;
                     Py : constant Natural := Row * Cell_H + Line;
                  begin
                     if (B / 32) mod 4 = 0 then
                        --  Control code (bits 5,6 clear): updates
                        --  state, the cell itself shows paper.
                        declare
                           Code : constant Natural := B mod 32;
                        begin
                           case Code is
                              when 0 .. 7 =>
                                 Ink := Color_Index (Code);
                              when 8 .. 15 =>
                                 Alt   := Code mod 2 = 1;
                                 Dbl   := (Code / 2) mod 2 = 1;
                                 Blink := (Code / 4) mod 2 = 1;
                              when 16 .. 23 =>
                                 Paper := Color_Index (Code - 16);
                              when others =>
                                 null;  --  24..31: video mode
                           end case;
                        end;
                        for P in 0 .. Cell_W - 1 loop
                           Fb (Py, Px + P) := Paper;
                        end loop;
                     else
                        --  Displayable character.
                        declare
                           Ch   : constant Natural := B mod 128;
                           Inv  : constant Boolean := (B / 128) mod 2 = 1;
                           CgB  : constant Natural :=
                             (if Alt then Charset_Alt else Charset_Std);
                           Gl   : constant Natural :=
                             (if Dbl
                              then Line / 2 + (if Row mod 2 = 1 then 4 else 0)
                              else Line);
                           Bits : constant Natural :=
                             Read (CgB + Ch * 8 + Gl);
                           Fg   : Color_Index :=
                             (if Blink and then Flash_On then Paper else Ink);
                           Bg   : Color_Index := Paper;
                           Tmp  : Color_Index;
                        begin
                           if Inv then
                              Tmp := Fg; Fg := Bg; Bg := Tmp;
                           end if;
                           for P in 0 .. Cell_W - 1 loop
                              if (Bits / (2 ** (5 - P))) mod 2 = 1 then
                                 Fb (Py, Px + P) := Fg;
                              else
                                 Fb (Py, Px + P) := Bg;
                              end if;
                           end loop;
                        end;
                     end if;
                  end;
               end loop;
            end;
         end loop;
      end loop;
   end Render;

   procedure Write_PPM (Fb : Framebuffer; File_Name : String)
   is
      use Ada.Streams.Stream_IO;
      F : File_Type;
      S : Stream_Access;

      function Img (N : Natural) return String is
         Raw : constant String := Natural'Image (N);
      begin
         return Raw (Raw'First + 1 .. Raw'Last);  --  drop leading space
      end Img;
   begin
      Create (F, Out_File, File_Name);
      S := Stream (F);
      String'Write
        (S, "P6" & ASCII.LF
            & Img (Width) & " " & Img (Height) & ASCII.LF
            & "255" & ASCII.LF);
      for Y in 0 .. Height - 1 loop
         for X in 0 .. Width - 1 loop
            declare
               C : constant RGB := Palette (Fb (Y, X));
            begin
               Character'Write (S, Character'Val (C.R));
               Character'Write (S, Character'Val (C.G));
               Character'Write (S, Character'Val (C.B));
            end;
         end loop;
      end loop;
      Close (F);
   end Write_PPM;

end Oric_Display;
