with Ada.Real_Time;
with Data_Types;

package Ticker is

   pragma Elaborate_Body;

   One_Tick : constant Ada.Real_Time.Time_Span
      := Ada.Real_Time.Nanoseconds (953);

   function Clock_Counter return Data_Types.T_Clock_Counter;
   function Clock_1Mhz_Counter return Data_Types.T_Clock_1Mhz_Counter;
   function Last_Tick return Ada.Real_Time.Time;
   function Last_1Mhz_Tick return Ada.Real_Time.Time;
   function Time_Used_Last_1Mhz return Duration;

   procedure Init_Clock;
   procedure Tick;

end Ticker;