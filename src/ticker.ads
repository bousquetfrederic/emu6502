with Data_Types;

package Ticker is

   pragma Elaborate_Body;

   --  An Oric runs the 6502 at 1 MHz and refreshes the screen at
   --  50 Hz, so one video frame is 20000 CPU cycles. We run the
   --  emulation a whole frame at a time and only synchronise with
   --  the wall clock once per frame, instead of sleeping on every
   --  single cycle (which no host OS scheduler can do at 1 MHz).
   Cycles_Per_Frame : constant := 20_000;

   function Clock_Counter return Data_Types.T_Clock_Counter;

   procedure Init_Clock;

   --  Account for one elapsed CPU cycle (no real-time wait).
   procedure Count_Cycle;

   --  Called once a whole frame of cycles has run; sleeps until
   --  the next 20 ms frame boundary so emulation tracks 1 MHz.
   procedure End_Of_Frame;

end Ticker;
