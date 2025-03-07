with Data_Bus.Logging;

package body Data_Bus is

   procedure Connect_Device
      (Bus    : in out T_Data_Bus;
       Device :        T_Data_Device)
   is
      Found_Empty_Spot  : Boolean := False;
      Empty_Spot_Number : T_Connected_Device_Nb;
      New_Device_AS     : constant Connectables.T_Address_Space
        := Device.Get_Address_Space;
      Existing_Dev_AS   : Connectables.T_Address_Space;
      use all type Connectables.T_Address_Space;
   begin
      Find_Empty_Spot :
      for Dev in Bus.Devices'Range loop
         if not Found_Empty_Spot
           and then Bus.Devices (Dev) = null
         then
            Found_Empty_Spot := True;
            Empty_Spot_Number := Dev;
         elsif Bus.Devices (Dev) /= null
         then
            --  existing device, check address space
            Existing_Dev_AS := Bus.Devices (Dev).Get_Address_Space;
            if not Address_Spaces_Separated (New_Device_AS, Existing_Dev_AS)
            then
               raise Data_Bus_Address_Range_Overlapping
               with New_Device_AS.First_Address'Image & " .. " &
                     New_Device_AS.Last_Address'Image & " vs " &
                     Existing_Dev_AS.First_Address'Image & " .. " &
                     Existing_Dev_AS.Last_Address'Image;
            end if;
         end if;
      end loop Find_Empty_Spot;
      if Found_Empty_Spot then
         Bus.Devices (Empty_Spot_Number) := Device;
      else
         raise Data_Bus_Too_Many_Devices;
      end if;
   end Connect_Device;

   function Read_Byte (Bus      : T_Data_Bus;
                       Address  : Data_Types.T_Address)
   return Data_Types.T_Byte is
      use all type Connectables.T_Address_Space;
      Value : Data_Types.T_Byte;
   begin
      for Dev of Bus.Devices loop
         if Dev /= null
            and then Connectables.Address_In_Address_Space
                       (Address, Dev.Get_Address_Space)
         then
            Value := Connectables.Read_Byte (Dev.all, Address);
            Logging.Dump_Read (Address, Value);
            return Value;
         end if;
      end loop;
      raise Data_Bus_No_Device_For_Address
        with Address'Image;
   end Read_Byte;

   procedure Tick (Bus : in out T_Data_Bus)
   is
   begin
      for Dev of Bus.Devices loop
         if Dev /= null then
            Dev.Tick;
         end if;
      end loop;
   end Tick;

   procedure Write_Byte (Bus     :        T_Data_Bus;
                         Address :        Data_Types.T_Address;
                         Value   :        Data_Types.T_Byte)
   is
      Found : Boolean := False;
   begin
      for Dev of Bus.Devices loop
         if Dev /= null
            and then Connectables.Address_In_Address_Space
                       (Address, Dev.Get_Address_Space)
         then
            Logging.Dump_Write (Address, Value);
            Connectables.Write_Byte (Dev.all, Address, Value);
            Found := True;
         end if;
      end loop;
      if not Found then
         raise Data_Bus_No_Device_For_Address
           with Address'Image;
      end if;
   end Write_Byte;

end Data_Bus;