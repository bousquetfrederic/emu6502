package Connectables.Video is

   type T_Video (First_Address : Data_Types.T_Address;
                 Lines         : Positive;
                 Columns       : Positive)
   is new T_Connectable with private;

   type T_Video_Ptr is access all T_Video;

   overriding
   function Read_Byte (Vid     : T_Video;
                       Address : Data_Types.T_Address)
   return Data_Types.T_Byte;

   overriding
   procedure Write_Byte
     (Vid     : in out T_Video;
      Address :        Data_Types.T_Address;
      Value   :        Data_Types.T_Byte);

   procedure Refresh (Vid : T_Video);

private

   type T_Video (First_Address : Data_Types.T_Address;
                 Lines         : Positive;
                 Columns       : Positive)
   is new T_Connectable
   with record
      Address : Data_Types.T_Address := First_Address;
      Data    : Data_Types.T_Byte_Grid (1 .. Lines, 1 .. Columns)
        := (others => (others => 32));
   end record;

   overriding
   function Get_Address_Space (Vid : T_Video)
   return T_Address_Space;

end Connectables.Video;