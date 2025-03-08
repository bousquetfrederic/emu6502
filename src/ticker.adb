package body Ticker is

   I_Clock_Counter : Data_Types.T_Clock_Counter := 1;
   I_Clock_1Mhz_Counter : Data_Types.T_Clock_1Mhz_Counter := 1;
   I_Last_Tick : Ada.Real_Time.Time;
   I_Last_1Mhz_Tick : Ada.Real_Time.Time;
   I_Actual_Time_Used_So_Far : Ada.Real_Time.Time_Span;
   I_Actual_Time_Used_Last_1Mhz : Ada.Real_Time.Time_Span;

   function Clock_Counter return Data_Types.T_Clock_Counter
   is (I_Clock_Counter);

   function Clock_1Mhz_Counter return Data_Types.T_Clock_1Mhz_Counter
   is (I_Clock_1Mhz_Counter);

   function Last_Tick return Ada.Real_Time.Time
   is (I_Last_Tick);
   function Last_1Mhz_Tick return Ada.Real_Time.Time
   is (I_Last_1Mhz_Tick);

   function Time_Used_Last_1Mhz return Duration
   is (Ada.Real_Time.To_Duration (I_Actual_Time_Used_Last_1Mhz));

   procedure Init_Clock
   is
   begin
      I_Last_Tick := Ada.Real_Time.Clock;
      I_Last_1Mhz_Tick := I_Last_Tick;
      I_Actual_Time_Used_So_Far := Ada.Real_Time.Time_Span_Zero;
      I_Actual_Time_Used_Last_1Mhz := Ada.Real_Time.Time_Span_Zero;
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
      Actual_Duration_Last_Tick : constant Ada.Real_Time.Time_Span
        := Time_Now - I_Last_Tick;
   begin
      I_Actual_Time_Used_Last_1Mhz :=
        I_Actual_Time_Used_Last_1Mhz + Actual_Duration_Last_Tick;
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
         I_Last_1Mhz_Tick := I_Last_Tick;
         I_Actual_Time_Used_Last_1Mhz
           := I_Actual_Time_Used_So_Far;
         I_Actual_Time_Used_So_Far
           := Ada.Real_Time.Time_Span_Zero;
      end if;
   end Tick;

end Ticker;