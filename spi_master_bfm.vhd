---------------------------------------------------------------------------
-- File           : spi_master_bfm.vhd
-- Author(s)      : Nikola Avramovic
---------------------------------------------------------------------------
-- Descripiton    : SPI BFM will be used for defining basic 
--                  interface functionalitiy.
---------------------------------------------------------------------------

library ieee, work;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;
   use work.handshake_pkg.all;
   use work.spi_master_bfm_pkg.all;

entity spi_master_bfm is
   generic(
      G_HANDLE_NO : TYPE_SPI_BFM_HANDLE_NO := 0
   );
   port (
      clk     : in  std_logic;        -- system clock - 50 MHz
      rst_in  : in  std_logic;        -- asynchronous reset - active high

      -- SPI link
      SCLK    : out  std_logic;
      CS_b    : out  std_logic;
      MOSI    : out  std_logic;
      MISO    : in   std_logic
   );
end entity;

architecture behavioral of spi_master_bfm is
   -- frame internal signals
   signal send_one_frame        : std_logic_vector(CONST_SPI_FRAME_WIDTH-1 downto 0);
   signal send_frame_ack        : boolean := false; --máme data který mùžem poslat
   signal send_frame_req        : boolean := false; --pokud máme data k poslání -> 0, poku data pošlem 1
   signal frame_length          : natural := 0;
   -- monitor internal signals
   signal receive_one_frame     : std_logic_vector(CONST_SPI_FRAME_WIDTH-1 downto 0);
   signal record_slave_data     : boolean := false; --pokud true, pøijímáme data ze slave

   -- SCLK internal signals
   signal start_spi_clk         : boolean := false;
   signal spi_clk_stop          : boolean := false;
   signal SCLK_sig              : std_logic;
   signal CS_b_sig              : std_logic;

begin

   -- -------------------------------------------------------------------------
   -- Command Process
   -- -------------------------------------------------------------------------
   command_p : process
      variable cmd : T_BFM_CMD;
   begin
      -- Initial output state
      hSPIBfm(G_HANDLE_NO).ack <= '0';
      report "BFM setted up";
      wait for 0 ns;            -- Wait for delta cycle

      loop
         -- Get request
         bfm_wait_for_request(hSPIBfm(0));
         cmd := get_bfm_cmd(0);
         bfm_ack_request(hSPIBfm(0));
         wait for 0 ns;            -- Wait for delta cycle

         -- Process Request
			--nahrajem data do send_one_frame, potvrdíme možnost odeslání, poèkáme na odeslání
         case cmd.op is
            when SEND_FRAME =>
               send_one_frame      <= cmd.frame_data;
               frame_length        <= cmd.frame_len;
               send_frame_ack      <= true;
               wait until send_frame_req;
               send_frame_ack      <= false;
               wait for 10 ns;      -- Wait for delta cycle
					report "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";
            when MONITOR_SALVE_OUTPUT =>
               
               -- wait to receive all burst data
               while not record_slave_data loop
                  wait for 20 ns; --èekáme na výsledek
               end loop;

               cmd.received_data := receive_one_frame;
              
               wait for 0 ns;      -- Wait for delta cycle

            when others =>
               NULL;
         end case;
      end loop;
   end process;

   -- ---------------------------------------------------------------------
   -- SPI generator process
   -- ---------------------------------------------------------------------
   generator_p : process
      variable frame_no    : natural := 0;
   begin
      wait until rst_in = '0';
      MOSI                     <= '0';
      wait for 0 ns;     -- Wait for delta cycle

      loop
         wait until send_frame_ack;

         if not send_frame_req then
            start_spi_clk      <= true;

            for i in 0 to frame_length-1 loop
						wait until falling_edge(SCLK_sig);
						MOSI <= send_one_frame(i);
               -- TODO: send SPI frame
					

               if (i = frame_length-1) then
                  send_frame_req <= true;
                  wait for 0 ns;

               end if;
            end loop;

            wait until spi_clk_stop;
            start_spi_clk      <= false;
         end if;
         
         if not send_frame_ack then
            send_frame_req   <= false;
         end if;

      end loop;

   end process;


   ---------------------------------------------------------------------
   -- SPI clk process
   ---------------------------------------------------------------------
   spi_clk_p : process
   begin
      wait until (rst_in = '0');
      CS_b_sig                 <= '1';
      SCLK_sig                 <= '1';
      wait for 0 ns;     -- Wait for delta cycle

      loop
         wait until start_spi_clk;
         spi_clk_stop          <= false;
			CS_b_sig <= '0';
			wait for tm_SCLK_per/4;
			SCLK_sig <= '0';
         -- TODO: Start SPI frame (set SCLK_sig and CS_b_sig)
         
         for i in 1 to frame_length-1 loop
            -- rising edge - master sample data (and read from slave?) to sample = to read
            -- TODO: SPI frame write
				wait for tm_SCLK_per/2; --ehm
				SCLK_sig              <= '1';
				--send èíslo
				
				wait for tm_SCLK_per/2; --ehm
				SCLK_sig              <= '0';
            -- falling edge - master send data
            -- TODO: SPI frame read

         end loop;
			
         -- TODO: Stop SPI frame (deassert SCLK_sig and CS_b_sig)
         wait for tm_SCLK_per/2;
         SCLK_sig              <= '1';
         wait for tm_CS_b_dly;
         CS_b_sig              <= '1';
         
         spi_clk_stop          <= true;
      end loop;
   end process;

   SCLK                        <= SCLK_sig;
   CS_b                        <= CS_b_sig;

   -- ---------------------------------------------------------------------
   -- SPI monitor process
   -- ---------------------------------------------------------------------
   monitor_p : process
   begin
      wait until (rst_in = '0');
      wait for 0 ns;     -- Wait for delta cycle

      loop
         wait until CS_b_sig = '0';
         record_slave_data           <= false;

         for i in 0 to frame_length-1 loop
            -- TODO: read SPI data
            wait until rising_edge(SCLK_sig);
				receive_one_frame(i) <= MISO;	
         end loop;

         record_slave_data           <= true;
         wait until spi_clk_stop;
         
         report "SPI MONITOR: " & to_hstring(receive_one_frame);
         receive_one_frame          <= (others => 'U');
      end loop;
   end process;
   
   
  
end behavioral;
