with SDL;
with SDL.Events;
with SDL.Events.Events;
with SDL.Video.Windows;
with SDL.Video.Windows.Makers;
with SDL.Video.Renderers;
with SDL.Video.Renderers.Makers;
with SDL.Video.Textures;
with SDL.Video.Textures.Makers;
with SDL.Video.Pixel_Formats;

package body Screen is

   use type SDL.Events.Event_Types;
   use type SDL.Dimension;

   type Pixel is mod 2 ** 32 with Convention => C;

   --  Canonical Oric palette pre-baked into ARGB_8888 (0xAARRGGBB).
   Palette : constant array (Oric_Display.Color_Index) of Pixel :=
     (0 => 16#FF00_0000#,   --  black
      1 => 16#FFFF_0000#,   --  red
      2 => 16#FF00_FF00#,   --  green
      3 => 16#FFFF_FF00#,   --  yellow
      4 => 16#FF00_00FF#,   --  blue
      5 => 16#FFFF_00FF#,   --  magenta
      6 => 16#FF00_FFFF#,   --  cyan
      7 => 16#FFFF_FFFF#);  --  white

   type Pixel_Buffer is
     array (Natural range 0 .. Oric_Display.Width * Oric_Display.Height - 1)
     of aliased Pixel with Convention => C;
   type Pixel_Buffer_Access is access all Pixel_Buffer;

   procedure Lock_Texture is new SDL.Video.Textures.Lock
     (Pixel_Pointer_Type => Pixel_Buffer_Access);

   Win      : SDL.Video.Windows.Window;
   Renderer : SDL.Video.Renderers.Renderer;
   Texture  : SDL.Video.Textures.Texture;

   procedure Open (Title : String; Scale : Positive := 3)
   is
      Native : constant SDL.Positive_Sizes :=
        (Width  => Oric_Display.Width,
         Height => Oric_Display.Height);
   begin
      if not SDL.Initialise (SDL.Enable_Screen) then
         raise Program_Error with "SDL initialisation failed";
      end if;

      SDL.Video.Windows.Makers.Create
        (Win      => Win,
         Title    => Title,
         Position => (X => 100, Y => 100),
         Size     => (Width  => Native.Width  * SDL.Dimension (Scale),
                      Height => Native.Height * SDL.Dimension (Scale)),
         Flags    => SDL.Video.Windows.Shown);

      SDL.Video.Renderers.Makers.Create (Renderer, Win);

      SDL.Video.Textures.Makers.Create
        (Tex      => Texture,
         Renderer => Renderer,
         Format   => SDL.Video.Pixel_Formats.Pixel_Format_ARGB_8888,
         Kind     => SDL.Video.Textures.Streaming,
         Size     => Native);
   end Open;

   procedure Present (Fb : Oric_Display.Framebuffer)
   is
      Pixels : Pixel_Buffer_Access;
   begin
      Lock_Texture (Texture, Pixels);
      for Y in 0 .. Oric_Display.Height - 1 loop
         for X in 0 .. Oric_Display.Width - 1 loop
            Pixels (Y * Oric_Display.Width + X) := Palette (Fb (Y, X));
         end loop;
      end loop;
      SDL.Video.Textures.Unlock (Texture);

      Renderer.Clear;
      Renderer.Copy (Texture);
      Renderer.Present;
   end Present;

   function Quit_Requested return Boolean
   is
      E : SDL.Events.Events.Events;
   begin
      while SDL.Events.Events.Poll (E) loop
         if E.Common.Event_Type = SDL.Events.Quit then
            return True;
         end if;
      end loop;
      return False;
   end Quit_Requested;

   procedure Close
   is
   begin
      SDL.Finalise;
   end Close;

end Screen;
