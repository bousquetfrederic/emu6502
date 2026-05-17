with Oric_Display;

--  Thin SDL2 presenter. Knows nothing about the Oric: it just
--  opens a window and blits an Oric_Display.Framebuffer. All the
--  emulation-accurate work lives in Oric_Display, so this layer
--  can be swapped (PPM, network, ...) without touching it.
package Screen is

   --  Open a window Scale times the native 240x224.
   procedure Open (Title : String; Scale : Positive := 3);

   --  Upload and display one framebuffer.
   procedure Present (Fb : Oric_Display.Framebuffer);

   --  True once the user has closed the window.
   function Quit_Requested return Boolean;

   procedure Close;

end Screen;
