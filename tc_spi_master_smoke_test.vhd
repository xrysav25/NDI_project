---------------------------------------------------------------------------
-- Project        : AAU slave
---------------------------------------------------------------------------
-- File           : tc_spi_master_smoke_test.vhd
-- Author(s)      : Nikola Avramovic
-- Created        : October 20th, 2021
---------------------------------------------------------------------------
-- Description    : This test procedure has been created to check basic 
--  function of SPI AAU slave
--      
---------------------------------------------------------------------------

library ieee, std;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;
   use std.textio.all;
   use work.spi_master_bfm_pkg.all;
   -- TODO add proper package

entity tc_spi_master_smoke_test is
end tc_spi_master_smoke_test;

architecture behavioral of tc_spi_master_smoke_test is

begin

   test_bench_i : entity work.tb(behavioral)
   generic map(
      STOP_TC   => false
   );

   test_case_p : process
   begin
      wait for 10 us;
      report "#### test case inicialisation ####";

      wait for 100 us;
      
		send_one_frame(hSPIBfm(0), X"119A"); -- platný rámec
--      send_one_frame(hSPIBfm(0), X"0518");
      report "----------------> first frame sent.";

      wait for 100 us;
   
--		send_wrong_frame(hSPIBfm(0), X"0FFFFF");   -- krátký rámec
      send_one_frame(hSPIBfm(0), X"119B");
      report "----------------> second frame is sent.";

      wait for 100 us;

		
		send_one_frame(hSPIBfm(0), X"0000");
      report "----------------> ningth frame is sent.";

      wait for 100 us;
      
      send_one_frame(hSPIBfm(0), X"0000");
      report "----------------> tenth frame is sent.";
     
      wait for 100 us;


      
		
      -- Send one SPI packet
 --     send_one_packet (
 --        handle                => hSPIBfm(0),
         -- TODO: add new procedure);
			

      report "***** First packet is sent. *****" severity failure;

      ---------------------------------------------
      -- TODO: send error frames
      ---------------------------------------------

      wait for 100 us;
 
      wait;
   end process;

  
end;

