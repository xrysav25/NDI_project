----------------------------------------------------------------------------------
-- Company:        Department of Microelectronics BUT
-- Engineer:       Vojtech Dvorak
--
-- Create Date:    26.9.2021
-- Module Name:    aau_pkg.vhd
-- Project Name:   BPC-NDI Auxiliary Arithmetic Unit
-- Description:    AAU package
--
-- Code Revision:  0.0.1
-- Specification:  AAU-RS-BUT-0001 Iss1.0
-- Comments:       Code to be finnished - missing values of constants (empty space)
--                 No additional constant should be necesssary
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package aau_pkg is

-- SPI IF parameters
constant c_DATA_W       : natural := 16;    -- frame length (digit has 16 bits) -> 15 nebo 16?
constant c_DATA_CNT_W   : natural := 0;     -- frame length counter, bitwidth ??
constant c_DATA_CNT_MAX : natural := 15;    -- frame length counter, max value  ??
constant c_DATA_W_MUL	: natural := 8;	  -- need to be count !! c_DATA_W/2

-- packet control parameters - watchdog timer
--constant c_TIMER_W      : natural := ;                        -- timer bitwidth
--constant c_TIMER_MAX    : unsigned(c_TIMER_W-1 downto 0);     -- k èemu to je?
--constant c_TIMER_       := to_unsigned(, c_TIMER_W);          -- timer max value

-- arithmetic unit
constant c_NUM_FRAC     : natural := 8;     -- decimal point




end aau_pkg;
