with Data_Types;

package Cpu.Debug is

   function Get_PC (Proc : T_Cpu) return Data_Types.T_Address;
   function Get_A (Proc : T_Cpu) return Data_Types.T_Byte;
   function Get_X (Proc : T_Cpu) return Data_Types.T_Byte;
   function Get_Y (Proc : T_Cpu) return Data_Types.T_Byte;
   function Get_SP (Proc : T_Cpu) return Data_Types.T_Byte;
   function Get_SR (Proc : T_Cpu) return Data_Types.T_Byte;

   procedure Set_PC (Proc : in out T_Cpu; PC : Data_Types.T_Address);
   procedure Set_A (Proc : in out T_Cpu; A : Data_Types.T_Byte);
   procedure Set_X (Proc : in out T_Cpu; X : Data_Types.T_Byte);
   procedure Set_Y (Proc : in out T_Cpu; Y : Data_Types.T_Byte);
   procedure Set_SP (Proc : in out T_Cpu; SP : Data_Types.T_Byte);
   procedure Set_SR (Proc : in out T_Cpu; SR : Data_Types.T_Byte);

end Cpu.Debug;