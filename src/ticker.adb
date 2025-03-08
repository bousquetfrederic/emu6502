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
      use type Ada.Real_Time.Time_Span;
      use type Ada.Real_Time.Time;
      Time_Now : constant Ada.Real_Time.Time
        := Ada.Real_Time.Clock;
      Expected_Duration_This_1Mhz : constant Ada.Real_Time.Time_Span
        := One_Tick * Integer (I_Clock_1Mhz_Counter);
      Actual_Duration_This_1Mhz : constant Ada.Real_Time.Time_Span
        := Time_Now - I_Last_1Mhz_Tick;
   begin
      --  if we are not running late, wait
      if Actual_Duration_This_1Mhz
         < Expected_Duration_This_1Mhz
      then
         delay until I_Last_Tick + One_Tick;
      end if;

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