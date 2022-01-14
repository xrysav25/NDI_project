----------------------------------------------------------------------------------
-- Company:        Department of Microelectronics BUT
-- Engineer:       Vojtech Dvorak
--
-- Create Date:    26.9.2021
-- Module Name:    top_aau.vhd
-- Project Name:   BPC-NDI Auxiliary Arithmetic Unit
-- Description:    Top level of Auxiliary Arithmetic Unit
--
-- Code Revision:  0.0.1
-- Specification:  AAU-RS-BUT-0001 Iss1.0
-- Comments:       Structural Description of AAU.
--                 Components:
--                      1. Reset controller
--                      2. SPI I/F
--                      3. Packet controller
--                      4. Arithmetic Unit
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

use work.aau_pkg.all;

entity top_aau is
    port (
        clk     : in  std_logic;        -- system clock - 50 MHz
        rst_in  : in  std_logic;        -- asynchronous reset - active high

        -- SPI link
        SCLK    : in  std_logic;
        CS_b    : in  std_logic;
        MOSI    : in  std_logic;
        MISO    : out std_logic
    );
end top_aau;

architecture structural of top_aau is
-- signal declaration
signal rst, rst_dly : std_logic;

-- data signals
signal data_mosi    : std_logic_vector(c_DATA_W-1 downto 0);
signal data_miso    : std_logic_vector(c_DATA_W-1 downto 0);
signal au_res_add   : std_logic_vector(c_DATA_W-1 downto 0);
signal au_res_mul   : std_logic_vector(c_DATA_W-1 downto 0);

-- link control signals
signal spi_err  : std_logic;
signal fr_end   : std_logic;
signal fr_start : std_logic;
signal we_miso_reg  : std_logic;

-- au control signals
signal we_au_reg_1, we_au_reg_2   : std_logic;

-- component declaration
-- no declaration, components as per VHDL-93

begin

----------------------------------------------------------------------------------
-- Reset controller --
----------------------------------------------------------------------------------
-- main system reset (signal rst) is asserted asynchronously and released with 
-- rising edge of clk. Reset is held 2 clk periods (2 rising edges) 
p_rst_ctrl : process (clk, rst_in)
    begin
        if rst_in = '1' then
            rst_dly  <= '1';
            rst      <= '1';
        else
            if rising_edge(clk) then
                rst_dly  <= '0';
                rst      <= rst_dly;
            end if;
        end if;
    end process;

----------------------------------------------------------------------------------
-- SPI I/F --
----------------------------------------------------------------------------------
i_spi_if : entity work.spi_if(rtl)
    port map(
        -- generic inputs
        clk     => clk,
        rst     => rst,
        
        -- SPI link
        SCLK    => SCLK,
        CS_b    => CS_b,
        MOSI    => MOSI,
        MISO    => MISO,
        
        -- data input/output
        data_mosi   => data_mosi,
        data_miso   => data_miso,
        we_data_miso=> we_miso_reg,
        
        -- frame identification
        spi_err => spi_err,
        fr_end  => fr_end,
        fr_start=> fr_start
        
            
    );
    
    
----------------------------------------------------------------------------------
-- Link ctrl --
----------------------------------------------------------------------------------
i_link_ctrl : entity work.pkt_ctrl(rtl)
    port map(
        -- generic inputs
        clk     => clk,
        rst     => rst,
        
        -- user inputs/outputs
        -- SPI IF
--         pkt_num => pkt_num,
        spi_err     => spi_err,
        fr_end      => fr_end,
        fr_start    => fr_start,
        we_tx_reg   => we_miso_reg,
        data_miso   => data_miso,
        
        -- AU IF
        we_au_reg_1 => we_au_reg_1, 
        we_au_reg_2 => we_au_reg_2,
        au_res_add  => au_res_add,
        au_res_mul  => au_res_mul
        
    );


----------------------------------------------------------------------------------
-- Arithemtic Unit --
----------------------------------------------------------------------------------
i_arith_unit : entity work.arith_unit(rtl)
    port map(
        -- generic inputs
        clk     => clk,
        rst     => rst,
        
        -- user inputs/outputs
        we_au_reg_1 => we_au_reg_1, 
        we_au_reg_2 => we_au_reg_2,
        
        data_au_in  => data_mosi,
        au_res_add  => au_res_add,
        au_res_mul  => au_res_mul
    );

    
end structural;

        
