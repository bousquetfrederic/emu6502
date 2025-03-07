with Ada.Real_Time;
with Data_Types;

package Ticker is

   One_Tick : constant Ada.Real_Time.Time_Span
      := Ada.Real_Time.Nanoseconds (953);

   function Clock_Counter return Data_Types.T_Clock_Counter;
   function Clock_1Mhz_Counter return Data_Types.T_Clock_1Mhz_Counter;
   function Last_Tick return Ada.Real_Time.Time;
   function Last_1Mhz_Tick return Ada.Real_Time.Time;
   function Duration_Of_Last_1Mhz_Tick return Duration;

   procedure Init_Clock;
   procedure Tick;

private

   I_Clock_Counter : Data_Types.T_Clock_Counter := 1;
   I_Clock_1Mhz_Counter : Data_Types.T_Clock_1Mhz_Counter := 1;

   function Clock_Counter return Data_Types.T_Clock_Counter
   is (I_Clock_Counter);

   function Clock_1Mhz_Counter return Data_Types.T_Clock_1Mhz_Counter
   is (I_Clock_1Mhz_Counter);

   I_Last_Tick : Ada.Real_Time.Time;
   I_Last_1Mhz_Tick : Ada.Real_Time.Time;
   I_Duration_Of_Last_1Mhz_Tick : Duration;

   function Last_Tick return Ada.Real_Time.Time
   is (I_Last_Tick);
   function Last_1Mhz_Tick return Ada.Real_Time.Time
   is (I_Last_1Mhz_Tick);
   function Duration_Of_Last_1Mhz_Tick return Duration
   is (I_Duration_Of_Last_1Mhz_Tick);

end Ticker;