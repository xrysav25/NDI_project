---------------------------------------------------------------------------
-- Copyright (c) 2018, TTTech Computertechnik AG
-- Project        : TTP Hub/Codec FPGA
---------------------------------------------------------------------------
-- File           : tb.vhd
-- Author(s)      : Nikola Avramovic
-- Created        : January 22nd, 2018
---------------------------------------------------------------------------
-- Description    :  Test Bench for Protocol Aware HW tester 
---------------------------------------------------------------------------

library ieee;
   use ieee.std_logic_1164.ALL;
   use ieee.numeric_std.all;
   use work.spi_master_bfm_pkg.all;

entity tb is
    generic (
        STOP_TC   : boolean := false
    );
end tb;

architecture behavioral of tb is
   -------------------------------------------------------------------------
   -- CONSTANTS
   -------------------------------------------------------------------------
   constant C_CLK_PERIOD      : time    := 20 ns;

   -------------------------------------------------------------------------
   -- Testbench control
   -------------------------------------------------------------------------
   signal clk     : std_logic;
   signal reset   : std_logic;

   ------------------------------------------------------------
   -- DUT signals
   ------------------------------------------------------------
   signal SCLK    : std_logic;
   signal CS_b    : std_logic;
   signal MOSI    : std_logic;
   signal MISO    : std_logic;

begin

  -----------------------------------------------------------------------------
  -- Clock process definitions
  -----------------------------------------------------------------------------  
   clk_p :process
   begin
      clk <= '0';
      wait for C_CLK_PERIOD/2;
      clk <= '1';
      wait for C_CLK_PERIOD/2;
   end process;

   -----------------------------------------------------------------------------
   -- Reset process can be changed to one line code
   --    reset_p :process
   --    begin
   --       wait for 10 ns;
   --       reset <= '1';
   --       wait for 200 ns;
   --       reset <= '0';
   --       wait;
   --    end process;
   -----------------------------------------------------------------------------  
   -- Toggle the reset after 5 clock periods
   reset   <= '1', '0' after 5 *C_CLK_PERIOD;

   -----------------------------------------------------------------------------
   -- SPI master BFM
   ----------------------------------------------------------------------------- 
   spi_master_bfm_i : entity work.spi_master_bfm
   port map(
        clk     => clk,
        rst_in  => reset,

        -- SPI link
        SCLK    => SCLK,
        CS_b    => CS_b, 
        MOSI    => MOSI, 
        MISO    => MISO
   );


   -----------------------------------------------------------------------------
   -- DUT AAU
   -----------------------------------------------------------------------------  
   top_aau_i: entity work.top_aau
    port map(
        clk     => clk,
        rst_in  => reset,

        -- SPI link
        SCLK    => SCLK,
        CS_b    => CS_b, 
        MOSI    => MOSI, 
        MISO    => MISO
    );

end behavioral;
