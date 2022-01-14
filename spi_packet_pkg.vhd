---------------------------------------------------------------------------
-- File           : spi_packet_pkg.vhd
-- Author(s)      : Nikola Avramovic
---------------------------------------------------------------------------
-- Descripiton    : This package will be used for creating a packet 
---------------------------------------------------------------------------

library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;
   use IEEE.std_logic_textio.all;
   use std.textio.all;
   use work.handshake_pkg.all;
   use work.spi_master_bfm_pkg.all;

package spi_packet_pkg is


   -- TODO: define packet array
   type packet is array (natural range <>) of std_logic;

   -- TODO: create send packet procedure
   procedure send_packet (
   --  TODO: define in/out variables/signals
    signal   handle           : inout tBfmHandle;
    --variable packet_data      : in std_logic_vector(CONST_SPI_PACKET_WIDTH-1 downto 0);
    constant packet_data      : in std_logic_vector(CONST_SPI_PACKET_WIDTH-1 downto 0);
    --variable received_data    : out std_logic_vector(CONST_SPI_PACKET_WIDTH-1 downto 0); 
    constant packet_len       : natural := 32
  );


end package;

package body spi_packet_pkg is

   -- TODO: create send packet procedure
   procedure send_packet (
   --  TODO: define in/out variables/signals
   signal   handle           : inout tBfmHandle;
   --variable packet_data      : in std_logic_vector(CONST_SPI_PACKET_WIDTH-1 downto 0); -- to by mìlo být to, co se zadá v tc_spi_... jako argument
   constant packet_data      : in std_logic_vector(CONST_SPI_PACKET_WIDTH-1 downto 0);
   --variable received_data    : out std_logic_vector(CONST_SPI_PACKET_WIDTH-1 downto 0); 
   constant packet_len       : natural := 32
   ) is
   begin
      send_one_frame(handle => handle, frame_data => packet_data(CONST_SPI_PACKET_WIDTH downto CONST_SPI_FRAME_WIDTH)); -- první pùlka paketu
      -- asi chvíli poèkat
      send_one_frame(handle => handle, frame_data => packet_data(CONST_SPI_FRAME_WIDTH downto 0)); -- druhá pùlka paketu
      --received_data := packet_data; -- tohle tomu nestaèí, poøešit co s received_data

   end send_packet;

end package body;