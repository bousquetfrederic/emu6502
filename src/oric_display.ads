with Data_Bus;

--  Oric ULA, TEXT mode (LORES 0, 40x28) software renderer.
--
--  This is deliberately NOT a bus device: on a real Oric the
--  screen and character generator are just RAM that the ULA
--  scans. We read that RAM through the bus once per frame and
--  produce a plain colour-index framebuffer. A presenter (PPM
--  file today, SDL window later) only has to blit it.
package Oric_Display is

   Width  : constant := 240;   --  40 columns * 6 pixels
   Height : constant := 224;   --  28 rows    * 8 pixels

   --  One of the 8 Oric RGB colours.
   type Color_Index is mod 8;

   type Framebuffer is
     array (Natural range 0 .. Height - 1,
            Natural range 0 .. Width - 1) of Color_Index;

   --  Render one TEXT-mode frame from screen RAM read via the bus.
   --  Frame is a free-running frame counter used for the flash
   --  attribute (the Oric flashes on bit 4 of the frame count).
   procedure Render
     (Bus   :     Data_Bus.T_Data_Bus;
      Frame :     Natural;
      Fb    : out Framebuffer);

   --  Write the framebuffer as a binary (P6) PPM image so the
   --  output is verifiable without a GUI; also serves as the
   --  test oracle for the renderer.
   procedure Write_PPM (Fb : Framebuffer; File_Name : String);

end Oric_Display;
