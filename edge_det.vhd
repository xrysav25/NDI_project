----------------------------------------------------------------------------------
-- Company:        Department of Microelectronics BUT
-- Engineer:       Vojtech Dvorak
--
-- Create Date:    26.9.2021
-- Module Name:    edge_det.vhd
-- Project Name:   BPC-NDI Auxiliary Arithmetic Unit
-- Description:    Top level of Auxiliary Arithmetic Unit
--
-- Code Revision:  0.0.1
-- Specification:  AAU-RS-BUT-0001 Iss1.0
-- Comments:       Edge detector - detects change in one bit stream 
--                  Rising edge (0->1)
--                  Falling edge (1->0)
--                 Functionality of module is TODO
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity edge_det is
    generic (
        g_RST_VAL   : std_logic := '0'
    );
    port (
        clk     : in  std_logic;
        rst     : in  std_logic;

        -- one bit input stream
        d_in    : in  std_logic;
        
        -- output flag - edge detected
        d_re    : out std_logic;
        d_fe    : out std_logic
    );
end edge_det;

architecture rtl of edge_det is
-- signal declaration - TODO
signal d_s : std_logic;

begin

p_reg : process (clk, rst)          -- TODO
    begin
        if rst = '1' then
				d_s <= g_RST_VAL;
        elsif rising_edge(clk) then
				d_s <= d_in;				--delay o 1 clk 
        end if;
    end process;
    
p_edge : process (d_in, d_s)      -- TODO
    begin
			if (d_in = '1' and d_s = '0') then
				d_re <= '1';			--zápis d_re
			else
				d_re <= '0';
			end if;	
			
			if (d_in = '0' and d_s = '1') then
				d_fe <= '1';			--zápis d_fe
			else
				d_fe <= '0';
			end if;	
				
    end process;

end rtl;

        
