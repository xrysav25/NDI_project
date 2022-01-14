---------------------------------------------------------------------------
-- File           : spi_master_bfm_pkg.vhd
-- Author(s)      : Nikola Avramovic
---------------------------------------------------------------------------
-- Descripiton    : SPI package will be used for defining basic 
--                  interface function.
---------------------------------------------------------------------------

library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;
   use IEEE.std_logic_textio.all;
   use std.textio.all;
   use work.handshake_pkg.all;

package spi_master_bfm_pkg is

   -- SPI Configuration
   constant CONST_SPI_FRAME_WIDTH  : natural := 16;
   constant CONST_SPI_PACKET_WIDTH : natural := 32;
   constant tm_SCLK_per            : time    := 1 us; -- TODO: add proper value of 
   constant tm_CS_b_dly            : time    := 2 us; -- TODO: add proper value

-- -------------------------------------------------------------------------
-- RECOMENDATION: DO NOT CHANGE ANYTHING AFTER THIS COMMENT!!!
-- -------------------------------------------------------------------------

   -- defines range of valid handle numbers
   subtype TYPE_SPI_BFM_HANDLE_NO is natural range 0 to 7;
   
   type T_OP_TYPE is (  SEND_FRAME,
                        MONITOR_SALVE_OUTPUT);

   -- BFM Command Type (Used for passing data between BFM and Package)
   type T_BFM_CMD is record
      op                       : T_OP_TYPE;
      received_data            : std_logic_vector(CONST_SPI_FRAME_WIDTH-1 downto 0);
      frame_data               : std_logic_vector(CONST_SPI_FRAME_WIDTH-1 downto 0);
      frame_len                : natural;
   end record;

   -- -------------------------------------------------------------------------
   -- PUBLIC PROCEDURES
   -- -------------------------------------------------------------------------
   -- Send one SPI frame
   procedure send_one_frame (
      signal   handle      : inout tBfmHandle;
      constant frame_data : std_logic_vector(CONST_SPI_FRAME_WIDTH-1 downto 0);
      constant frame_len  : natural  := 16
   ); 
	
	
   -- Send wrong SPI frame
   procedure send_wrong_frame (
      signal   handle      : inout tBfmHandle;
      constant frame_data : std_logic_vector(24-1 downto 0);
      constant frame_len  : natural  := 24
   ); 

   -- Monitor SPI slave output
   procedure monitor_slave_output (
     signal   handle          : inout tBfmHandle;
     variable received_data   : out std_logic_vector(CONST_SPI_FRAME_WIDTH-1 downto 0)
   ); 

   ----------------------------------------------------------------------------
   -- INTERNAL PROCEDURES (Only called by BFM)
   ----------------------------------------------------------------------------
   -- Reads command record   
   impure function get_bfm_cmd (handle_no: TYPE_SPI_BFM_HANDLE_NO) return T_BFM_CMD;

   -- BFM Handle
   signal  hSPIBfm : tBfmHandleArray(TYPE_SPI_BFM_HANDLE_NO) := tBfmHandleArray_init(TYPE_SPI_BFM_HANDLE_NO'high - TYPE_SPI_BFM_HANDLE_NO'low + 1);

end package;

package body spi_master_bfm_pkg is
 
   -- Command record variable used for communication between this package and GMII_GEN BFM
   type T_BFM_CMD_ARRAY is array (natural range <>) of T_BFM_CMD;
   shared variable bfm_cmd : T_BFM_CMD_ARRAY(TYPE_SPI_BFM_HANDLE_NO);

   ----------------------------------------------------------------------------
   -- PUBLIC PROCEDURES
   ----------------------------------------------------------------------------
   -- Send one SPI frame
   procedure send_one_frame (
      signal   handle          : inout tBfmHandle;
      constant frame_data      : std_logic_vector(CONST_SPI_FRAME_WIDTH-1 downto 0);
      constant frame_len       : natural := 16
   ) is
     constant idx              : TYPE_SPI_BFM_HANDLE_NO := to_integer(unsigned(handle.idx));
   begin
      bfm_cmd(idx).op          := SEND_FRAME;
      bfm_cmd(idx).frame_data  := frame_data;
      bfm_cmd(idx).frame_len   := frame_len;
      bfm_send_request(handle => handle, log_name => "SPI_MASTER_BFM");
   end send_one_frame;

   -- Send wrong SPI frame
   procedure send_wrong_frame (
      signal   handle          : inout tBfmHandle;
      constant frame_data      : std_logic_vector(24-1 downto 0);
      constant frame_len       : natural := 24
   ) is
     constant idx              : TYPE_SPI_BFM_HANDLE_NO := to_integer(unsigned(handle.idx));
   begin
      bfm_cmd(idx).op          := SEND_FRAME;
      bfm_cmd(idx).frame_data  := frame_data;
      bfm_cmd(idx).frame_len   := frame_len;
      bfm_send_request(handle => handle, log_name => "SPI_MASTER_BFM");
   end send_wrong_frame;

   -- Monitor SPI slave output
   procedure monitor_slave_output (
      signal   handle          : inout tBfmHandle;
      variable received_data   : out std_logic_vector(CONST_SPI_FRAME_WIDTH-1 downto 0)
   ) is
      constant idx             : TYPE_SPI_BFM_HANDLE_NO := to_integer(unsigned(handle.idx));
   begin
      bfm_cmd(idx).op          := MONITOR_SALVE_OUTPUT;
      bfm_send_request(handle => handle, log_name => "SPI_MASTER_BFM");
      received_data            := bfm_cmd(idx).received_data;
   end monitor_slave_output;

   ----------------------------------------------------------------------------
   -- INTERNAL PROCEDURES (Only called by BFM)
   ----------------------------------------------------------------------------   
   -- Reads command record   
   impure function get_bfm_cmd (handle_no: TYPE_SPI_BFM_HANDLE_NO) return T_BFM_CMD is
   begin
      return bfm_cmd(handle_no);
   end;
end package body;

