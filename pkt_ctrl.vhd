----------------------------------------------------------------------------------
-- Company:        Department of Microelectronics BUT
-- Engineer:       Vojtech Dvorak
--
-- Create Date:    26.9.2021
-- Module Name:    pkt_ctrl.vhd
-- Project Name:   BPC-NDI Auxiliary Arithmetic Unit
-- Description:    Packet controller
--
-- Code Revision:  0.0.1
-- Specification:  AAU-RS-BUT-0001 Iss1.0
-- Comments:       Packet controller identifies packet (start,end) and check its validity
--                 Code is incmoplete, only IF and structure defined
--                 
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use work.aau_pkg.all;

entity pkt_ctrl is
    port (
        clk     : in  std_logic;        -- system clock - 50 MHz
        rst     : in  std_logic;        -- asynchronous reset - active high

        -- user input/outputs
        -- frame identification
        fr_start    : in  std_logic;
        fr_end      : in  std_logic;
        spi_err     : in  std_logic;
        
        -- data to be send out (through SPI)
        we_tx_reg   : out std_logic; -- povolená zápisu !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! <=MAKEJ na tomhle
        data_miso   : out std_logic_vector(c_DATA_W-1 downto 0);
        
        -- data to/from AU
        we_au_reg_1 : out std_logic;    -- write enable to data 1 reg in AU (frame 1 received)
        we_au_reg_2 : out std_logic;    -- write enable to data 2 reg in AU (frame 2 received)
        au_res_add  : in  std_logic_vector(c_DATA_W-1 downto 0);    -- add result
        au_res_mul  : in  std_logic_vector(c_DATA_W-1 downto 0)     -- mul result
		  
    );
end pkt_ctrl;

architecture rtl of pkt_ctrl is
-- definition of packet FSM
type t_FSM_PKT_CTRL is (IDLE,                -- IDLE state, do nothing
                        RECIEVE_FR_1,        -- receiving frame 1
                        WAIT_FR_2,           -- wait on frame 2
                        RECIEVE_FR_2);       -- receiving frame 2

signal state : t_FSM_PKT_CTRL := IDLE;
signal next_state : t_FSM_PKT_CTRL;


--integer cnt_puls : 0;
signal cnt_puls, cnt_puls_1 : unsigned(17 downto 0); 
-- Watchdog timer 
signal tx_reg_c, tx_reg_s : std_logic;

begin

-- Create state register and timer register
p_reg: process (clk, rst)
    begin
        if rst = '1' then
				state <= IDLE;
        elsif rising_edge(clk) then
				state <= next_state; --!!
				cnt_puls <= cnt_puls_1;
				tx_reg_s <= tx_reg_c;
        end if;
    end process;
    
-- FSM logic
p_link_fsm: process (state, tx_reg_s, fr_start, au_res_add, fr_end, spi_err, cnt_puls, au_res_mul)
    begin
			--next_state <= state;
			data_miso   <= (others => '0');
			we_au_reg_1 <= '0';
			we_au_reg_2 <= '0';
			we_tx_reg   <= '0';
			cnt_puls_1 <= cnt_puls;
			case state is
				when IDLE =>
					cnt_puls_1 <= (others => '0');
					tx_reg_c <= tx_reg_s;
					if fr_start = '1' then
						next_state <= RECIEVE_FR_1;
					else
						next_state <= state;
					end if;
				
				when RECIEVE_FR_1 =>
					data_miso <= au_res_add;
					if tx_reg_s = '1' then
						we_tx_reg <= '1'; --když byl v minulém kole pøijat druhý frame
					end if;
					if fr_end = '1' then
						if spi_err = '0' then
							next_state <= WAIT_FR_2;
							we_au_reg_1 <= '1';
							tx_reg_c <= tx_reg_s;
						else
							next_state <= IDLE;
							tx_reg_c <= '0';
						end if;
					else
						tx_reg_c <= tx_reg_s;
						next_state <= state;
					end if;
				
				when WAIT_FR_2 =>
					-- timer 100ms
					if cnt_puls >= "110000110101000000" then --frekvence hodin 50MHz
					 	next_state <= IDLE;
						cnt_puls_1 <= (others => '0');
						tx_reg_c <= '0';
					elsif fr_start = '1' then
						next_state <= RECIEVE_FR_2;
						cnt_puls_1 <= (others => '0');
						tx_reg_c <= tx_reg_s;
					else
						cnt_puls_1 <= cnt_puls +1;
						next_state <= state;
						tx_reg_c <= tx_reg_s;
					end if;	
				
				when RECIEVE_FR_2 =>
					data_miso <= au_res_mul;
					if tx_reg_s = '1' then
						we_tx_reg <= '1'; --když byl v minulém kole pøijat druhý frame
					end if;
					if fr_end = '1' then
						if spi_err = '0' then
							next_state <= IDLE;
							we_au_reg_2 <= '1';
							tx_reg_c <= '1';
						else 
							next_state <= WAIT_FR_2;
							tx_reg_c <= tx_reg_s;
						end if;
					else
						next_state <= state;
						tx_reg_c <= tx_reg_s;
					end if;	
			
			end case;
    end process;
   
end rtl;

