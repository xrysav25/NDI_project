----------------------------------------------------------------------------------
-- Company:        Department of Microelectronics BUT
-- Engineer:       Vojtech Dvorak
--
-- Create Date:    26.9.2021
-- Module Name:    spi_if.vhd
-- Project Name:   BPC-NDI Auxiliary Arithmetic Unit
-- Description:    SPI Interface module
--
-- Code Revision:  0.0.1
-- Specification:  AAU-RS-BUT-0001 Iss1.0
-- Comments:       SPI IF module performs serialization (MISO) and deserialization (MOSI)
--                 of input/output data stream. 
--                 Code to be finnished - only IF and structure defined
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.aau_pkg.all;

entity spi_if is
    port (
        clk     : in  std_logic;        -- system clock - 50 MHz
        rst     : in  std_logic;        -- asynchronous reset - active high

        -- SPI link
        SCLK    : in  std_logic;
        CS_b    : in  std_logic;
        MOSI    : in  std_logic;
        MISO    : out std_logic;

        -- data input/output
        data_mosi       : out std_logic_vector(c_DATA_W-1 downto 0); -- send data to aritmetic logic							--chybí pøepisování tady tìch registrù!
        data_miso       : in  std_logic_vector(c_DATA_W-1 downto 0); -- from aritmetic logic -> data to be transmitted
        we_data_miso    : in  std_logic;
        
        -- frame identification - comments TODO
        fr_start    : out std_logic;
        fr_end      : out std_logic;
        spi_err     : out std_logic
        
    );
end spi_if;

architecture rtl of spi_if is
-- signal declaration
signal sclk_s, cs_b_s, mosi_s : std_logic;

-- CS_b & SCLK edge detector
signal cs_b_re_s : std_logic;
signal cs_b_fe_s : std_logic;
signal sclk_re_s : std_logic;
signal sclk_fe_s : std_logic;
signal we_re_s : std_logic;
signal we_fe_s : std_logic;

-- shift register - data receiver & transmitter
signal sr_reciever_s    : unsigned (c_DATA_W - 1 downto 0); --délka dat podle konstanty
signal sr_transmitter_s : unsigned (c_DATA_W - 1 downto 0);       

-- frame validity check - conetr of edges
signal scnt_rx_s, scnt_rx_s_1 : unsigned (c_DATA_W - 1 downto 0);
--signal s_check : std_logic;


begin
----------------------------------------------------------------------------------
-- Input Dual-DFF timing synchronization
----------------------------------------------------------------------------------
i_ddff_sclk : entity work.ddff(rtl) --REQ_AAU_G_002 
    generic map(
        g_RST_VAL => '0'			--resetovací hodnota pro tento blok
    )
    port map(
        clk     => clk,
        rst     => rst,
        d_in    => sclk,			--synchronizace SCLK
        d_out   => sclk_s  
    );
    
i_ddff_cs_b : entity work.ddff(rtl)
    generic map(
        g_RST_VAL => '0'
    )
    port map(
        clk     => clk,
        rst     => rst,
        d_in    => cs_b,			--synchronizace pro definici rámce
        d_out   => cs_b_s  
    );
    
i_ddff_mosi : entity work.ddff(rtl)
    generic map(
        g_RST_VAL => '0'
    )
    port map(
        clk     => clk,
        rst     => rst,
        d_in    => mosi,			--synchronizace pro data
        d_out   => mosi_s  
    );
    
----------------------------------------------------------------------------------
-- SCLK & CS_b Edge detector
----------------------------------------------------------------------------------
 i_edge_sclk : entity work.edge_det(rtl)
    generic map(
        g_RST_VAL => '0'
    )
    port map(
        clk     => clk,
        rst     => rst,
        d_in    => sclk_s,
        d_re    => sclk_re_s,			--jeden pulz pri rising edge 
        d_fe    => sclk_fe_s 			--jeden pulz pri falling edge
    );
 
 i_edge_cs_b : entity work.edge_det(rtl)
    generic map(
        g_RST_VAL => '0'
    )
    port map(
        clk     => clk,
        rst     => rst,
        d_in    => cs_b_s,
        d_re    => cs_b_re_s,
        d_fe    => cs_b_fe_s 
    ); 

 i_edge_we : entity work.edge_det(rtl)
    generic map(
        g_RST_VAL => '0'
    )
    port map(
        clk     => clk,
        rst     => rst,
        d_in    => we_data_miso,
        d_re    => we_re_s,
        d_fe    => we_fe_s 
    ); 

----------------------------------------------------------------------------------
-- Data receiver
----------------------------------------------------------------------------------
p_rx_data : process (clk, rst)
    begin
        if rst = '1' then
				sr_reciever_s <= (others => '0');
        elsif rising_edge(clk) then
                -- serial data are paralelized with shift register - LSb first -- registr je tam proto, aby pøijmul signál z Mastera, kde jde napøed MSB, my chceme napøed LSB
				if sclk_fe_s = '1' then--zapsat data
					sr_reciever_s <= shift_right(sr_reciever_s, 1); --REQ_ AAU_I_021 In data transfer, LSb shall be sent first. - takže naèítáme i nejménì významný bit první a cyklíme doprava
					sr_reciever_s(c_DATA_W - 1) <= mosi_s; -- na poslední místo zaøadíš, co ti pøišlo z mastera
				end if;

        end if;
    end process;

-- received data are assigned to output port (valid when - TODO - )

----------------------------------------------------------------------------------
-- Frame Detector with check of frame length
----------------------------------------------------------------------------------
p_frame_detector_s : process (clk, rst)
    begin
        if rst = '1' then
				scnt_rx_s <= (others => '0');
        elsif rising_edge(clk) then
            -- frame data counter
				scnt_rx_s <= scnt_rx_s_1;
				
        end if;
    end process;

p_frame_detector_c : process (cs_b_re_s, cs_b_fe_s, sclk_fe_s, scnt_rx_s)
    begin
    	  -- default assignment
		  scnt_rx_s_1 <= scnt_rx_s;
			if cs_b_fe_s = '1' then
				spi_err <= '1';
				scnt_rx_s_1(c_DATA_W - 1 downto 1) <= (others => '0');
				scnt_rx_s_1(0) <= '1';
			end if;	
         if sclk_fe_s = '1' then
				scnt_rx_s_1 <= rotate_left(scnt_rx_s, 1);
			end if;
		  
		   if cs_b_re_s = '1' then
				data_mosi <= std_logic_vector(sr_reciever_s);
				if scnt_rx_s(0) = '1' then --nebo implementovat counterem..?
					spi_err <= '0';
				else
					spi_err <= '1';	--zahodit a znovu.... -> co poslat masterovi? TODO
				end if;
			end if;
        -- edge counter
			
        
        -- check full counter frame REQ_ AAU_I_022 I (Frame with wrong number of bits shall be ignored)
		  -- REQ_ AAU_I_023 (When second frame is not received in 100ms (TBC) after the first frame was received, such packet shall be considered invalid.)
          
    end process;

-- output assignment - start and end of frame


            
----------------------------------------------------------------------------------
-- Data transmitter
----------------------------------------------------------------------------------
p_tx_reg: process (clk, rst)
    begin
        if rst = '1' then
				sr_transmitter_s <= (others => '0');
        elsif rising_edge(clk) then
                -- serial data are paralelized with shift register - LSb first -- registr je tam proto, aby pøijmul signál z Mastera, kde jde napøed MSB, my chceme napøed LSB
			if we_re_s = '1' then
				sr_transmitter_s <= unsigned(data_miso);
			end if;
			
				if sclk_re_s = '1' then--zapsat data
					sr_transmitter_s <= shift_right(sr_transmitter_s, 1); --REQ_ AAU_I_021 In data transfer, LSb shall be sent first. - takže naèítáme i nejménì významný bit první a cyklíme doprava
					MISO <= sr_transmitter_s(0); -- na poslední místo zaøadíš, co ti pøišlo z mastera
				end if;
			fr_start <= cs_b_fe_s;
			fr_end <= cs_b_re_s;
        end if;
    end process;

-- output assignment - some bit of shift register
--sr_transmitter_s


end rtl;

