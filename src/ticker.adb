package body Ticker is

   function Delta_Time
     (T1 : Ada.Real_Time.Time;
      T2 : Ada.Real_Time.Time)
   return Duration
   is
      use type Ada.Real_Time.Time;
   begin
      return (Ada.Real_Time.To_Duration
               (T2 - T1));
   end Delta_Time;

   procedure Init_Clock
   is
   begin
      I_Last_Tick := Ada.Real_Time.Clock;
      I_Last_1Mhz_Tick := I_Last_Tick;
      I_Duration_Of_Last_1Mhz_Tick
        := Delta_Time (I_Last_1Mhz_Tick, I_Last_Tick);
   end Init_Clock;

   procedure Tick
   is
      use type Data_Types.T_Clock_Counter;
      use type Data_Types.T_Clock_1Mhz_Counter;
   begin
      I_Clock_1Mhz_Counter := Clock_1Mhz_Counter + 1;
      I_Clock_Counter := Clock_Counter + 1;
      I_Last_Tick := Ada.Real_Time.Clock;
      if I_Clock_1Mhz_Counter = 0 then
            I_Duration_Of_Last_1Mhz_Tick
              := Delta_Time (I_Last_1Mhz_Tick, I_Last_Tick);
         I_Last_1Mhz_Tick := I_Last_Tick;
      end if;
   end Tick;

end Ticker;