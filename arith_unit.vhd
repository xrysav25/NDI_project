----------------------------------------------------------------------------------
-- Company:        Department of Microelectronics BUT
-- Engineer:       Vojtech Dvorak
--
-- Create Date:    26.9.2021
-- Module Name:    arith_unit.vhd
-- Project Name:   BPC-NDI Auxiliary Arithmetic Unit
-- Description:    Fixed-point Arithmetic Unit
--
-- Code Revision:  0.0.1
-- Specification:  AAU-RS-BUT-0001 Iss1.0
-- Comments:       Code to be finnished - only IF and structure defined
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use work.aau_pkg.all;

entity arith_unit is
    port (
        clk     : in  std_logic;        -- system clock - 50 MHz
        rst     : in  std_logic;        -- asynchronous reset - active high

        -- user input/outputs
        we_au_reg_1 : in  std_logic; --we =? write eneable
        we_au_reg_2 : in  std_logic;
        
        data_au_in  : in  std_logic_vector(c_DATA_W-1 downto 0); --dostanem postupnì èísla 
        au_res_add  : out std_logic_vector(c_DATA_W-1 downto 0); --vysypat výsledek sèítání
        au_res_mul  : out std_logic_vector(c_DATA_W-1 downto 0)  --vysypat výsledek násobení

    );
end arith_unit;

architecture rtl of arith_unit is
-- input data registers
signal num_1 : signed(c_DATA_W-1 downto 0);
signal num_2 : signed(c_DATA_W-1 downto 0);
-- pipeline register
signal p_res_add : signed(c_DATA_W downto 0);
signal p_res_mul : signed(2*c_DATA_W-1 downto 0);

-- results of arithmetic operations 
signal res_add_c, res_add_s : signed(c_DATA_W downto 0);
signal res_mul_c, res_mul_s : signed(2*c_DATA_W-1 downto 0);
-- write AU result registers
signal add_temp_s : std_logic;
signal mul_temp_s : std_logic;
signal add_temp_c : std_logic;
signal mul_temp_c : std_logic; -- <= pøidat cykly aby se propsal správnì výsledek... zjistit kolik cyklù trvá násobení
--signal mul_temp_c1, mul_temp_c2 : std_logic;


begin

-- create all registers in AU
p_reg: process (clk, rst)
    begin
        if rst = '1' then
				num_1 <= (others => '0');
				num_2 <= (others => '0');
				res_add_s <= (others => '0');
				res_mul_s <= (others => '0');
				add_temp_s <= '0';
				mul_temp_s <= '0';
				
        
            -- pipeline registers - reset value is not important, reset may be omitted

        elsif rising_edge(clk) then
					--write input data registers
					if we_au_reg_1 = '1' then
						num_1 <= signed(data_au_in);
					elsif we_au_reg_2 = '1' then
						num_2 <= signed(data_au_in);
					end if;
            -- pipeline register
					res_add_s <= res_add_c;
					res_mul_s <= res_mul_c;
            -- pøevod z vector => signed
				add_temp_c <= we_au_reg_2;
				add_temp_s <= add_temp_c;
				
				mul_temp_c <= we_au_reg_2;
				--mul_temp_c1 <= mul_temp_c;
				--mul_temp_c2 <= mul_temp_c1;
				
				mul_temp_s <= mul_temp_c;
				
            -- calculation finnished, write output registers -- TODO --           
            -- HINT: results are valid some time after second frame is received
            --       after that (during next packet), registers must not be writen
					if add_temp_s = '1' then
						au_res_add <= std_logic_vector(p_res_add(c_DATA_W-1 downto 0));
						add_temp_s <= '0';
					end if;
					
					if mul_temp_s = '1' then
						au_res_mul <= std_logic_vector(p_res_mul(23 downto 8));--(res_mul((3/2*c_DATA_W-1) downto (c_DATA_W/2)));
						mul_temp_s <= '0';
					end if;

            
        end if;
    end process;

p_add_1st_stage: 
    res_add_c <= resize(num_1, c_DATA_W+1)  + num_2;
		
    
p_add_2nd_stage: process (res_add_s)                   -- TODO --
    begin
	  -- positive number
	  --if add_temp_s = '0' then
				p_res_add <= res_add_s;
			  if res_add_s(c_DATA_W) = '0' then
					if (res_add_s(c_DATA_W-1) = '1') then --pøeteèení do kladných èísel --and num_1(c_DATA_W-1) = '0' and num_2(c_DATA_W-1) = '0'
						p_res_add <= (others => '0');
						p_res_add(c_DATA_W-2 downto 0)  <= (others => '1');
					end if;			  -- negative number
			  else --pøeteèení záporných èísel
					if (res_add_s(c_DATA_W-1) = '0') then
						p_res_add <= (others => '1');
						p_res_add(c_DATA_W-2 downto 0)  <= (others => '0');
					end if;
			  end if;
		--end if;
    end process;

    
p_mul_1st_stage: 
     res_mul_c <= num_1 * num_2;   
    
p_mul_2nd_stage: process (res_mul_s)                   -- TODO --
	variable temp : signed (c_DATA_W/2 downto 0) := (others => '1');
    begin
		  p_res_mul <= res_mul_s;
        		  -- positive number
        if res_mul_s(2*c_DATA_W-1) = '0' then
				if (res_mul_s(2*c_DATA_W-1 downto 3*c_DATA_W_MUL-1) /= 0) then --kontroluje první ètvrtinu bitù, mínus nejvyšší dva
					p_res_mul <= (others => '0');
					p_res_mul(3*c_DATA_W_MUL-2 downto c_DATA_W_MUL)  <= (others => '1');
				end if;
      -- negative number
        else
				if (res_mul_s(2*c_DATA_W-1 downto 3*c_DATA_W_MUL-1) /= temp) then --kontroluje první ètvrtinu bitù, mínus nejvyšší dva
					p_res_mul <= (others => '1');
					p_res_mul(3*c_DATA_W_MUL-2 downto c_DATA_W_MUL)  <= (others => '0');
				end if;
        end if;
        
    end process;    
end rtl;

