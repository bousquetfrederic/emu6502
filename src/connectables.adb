package body Connectables is

   procedure Tick (C : in out T_Connectable'Class)
   is
      use type Data_Types.T_Clock_Counter;
   begin
      C.Clock_Counter := C.Clock_Counter + 1;
   end Tick;

end Connectables;