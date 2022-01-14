----------------------------------------------------------------------------------
-- Company:        Department of Microelectronics BUT
-- Engineer:       Vojtech Dvorak
--
-- Create Date:    26.9.2021
-- Module Name:    ddff.vhd
-- Project Name:   BPC-NDI Auxiliary Arithmetic Unit
-- Description:    Double-DFF
--
-- Code Revision:  0.0.1
-- Specification:  AAU-RS-BUT-0001 Iss1.0
-- Comments:       Double DFF for synchronization of asynchronous signals
--                 Code is incmoplete, only IF and structure defined
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity ddff is
    generic (
        g_RST_VAL   : std_logic := '0'
    );
    port (
        clk     : in  std_logic;
        rst     : in  std_logic;

        -- SPI link
        d_in    : in  std_logic;
        d_out   : out std_logic
    );
end ddff;

architecture rtl of ddff is
-- signal declaration
signal d_s : std_logic;

begin

p_reg : process (clk, rst)
    begin
        if rst = '1' then	
				d_s <= g_RST_VAL;				--pri resetu chceme veschny hodnoty vsech signalu resetovaci hodnotu
				d_out <= g_RST_VAL;
        elsif rising_edge(clk) then
				d_s <= d_in;			--dvojty register, preklapeni
				d_out <= d_s;
        end if;
    end process;
   
end rtl;

        
