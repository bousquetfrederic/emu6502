with Connectables.Video.Logging;
with Ada.Text_IO; use Ada.Text_IO;

package body Connectables.Video is

   function Grid_Pos_To_Address
     (First_Address : Data_Types.T_Address;
      Line_Length   : Positive;
      Line          : Positive;
      Column        : Positive)
   return Data_Types.T_Address
   is
      use type Data_Types.T_Address;
      Up_To_Start_Of_Line : constant Natural
        := (Line - 1) * Line_Length;
      To_Column : constant Natural
        := Up_To_Start_Of_Line + Column - 1;
   begin
      return First_Address
             + Data_Types.T_Address
                 (To_Column);
   end Grid_Pos_To_Address;

   procedure Address_To_Grid_Pos
     (Address       :     Data_Types.T_Address;
      First_Address :     Data_Types.T_Address;
      Line_Length   :     Positive;
      Line          : out Positive;
      Column        : out Positive)
   is
      use type Data_Types.T_Address;
      Pos : constant Natural := Natural (Address - First_Address);
   begin
      Line := (Pos / Line_Length) + 1;
      Column := (Pos mod Line_Length) + 1;
      Put_Line ("ATGP Line=" & Line'Image &
                " Column=" & Column'Image &
                " FA=" & First_Address'Image &
                " Pos=" & Pos'Image);
   end Address_To_Grid_Pos;

   overriding
   function Get_Address_Space (Vid : T_Video)
   return T_Address_Space is
   (First_Address => Vid.Address,
    Last_Address  => Grid_Pos_To_Address
      (First_Address => Vid.Address,
       Line_Length   => Vid.Data'Last (2),
       Line          => Vid.Data'Last (1),
       Column        => Vid.Data'Last (2)));

   overriding
   function Read_Byte (Vid     : T_Video;
                       Address : Data_Types.T_Address)
   return Data_Types.T_Byte
   is
      Line, Col : Positive;
   begin
      if not Address_In_Address_Space (Address, Vid.Get_Address_Space)
      then
         raise Connectable_Address_Not_In_Range with Address'Image;
      else
         Address_To_Grid_Pos
           (Address       => Address,
            First_Address => Vid.Address,
            Line_Length   => Vid.Data'Last (2),
            Line          => Line,
            Column        => Col);
         return Vid.Data (Line, Col);
      end if;
   end Read_Byte;

   procedure Refresh (Vid  : T_Video;
                      File : Ada.Text_IO.File_Type)
   is
   begin
      Logging.Dump_Screen (Vid, File);
   end Refresh;

   overriding
   procedure Write_Byte
     (Vid     : in out T_Video;
      Address :        Data_Types.T_Address;
      Value   :        Data_Types.T_Byte)
   is
      Line, Col : Positive;
   begin
      if not Address_In_Address_Space (Address, Vid.Get_Address_Space)
      then
         raise Connectable_Address_Not_In_Range with Address'Image;
      else
         Address_To_Grid_Pos
           (Address       => Address,
            First_Address => Vid.Address,
            Line_Length   => Vid.Data'Last (2),
            Line          => Line,
            Column        => Col);
         Vid.Data (Line, Col) := Value;
      end if;
   end Write_Byte;

end Connectables.Video;