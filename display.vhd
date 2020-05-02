----------------------------------------------------------------------------------
-- Company: 
-- Engineer:       Aja, Stefan
-- 
-- Create Date:    20:24:07 10/09/2019 
-- Design Name: 
-- Module Name:    display - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity display is
    Port ( clk_i : in  STD_LOGIC;
           rst_i : in  STD_LOGIC;
           digit_i : in  STD_LOGIC_VECTOR (31 downto 0);
           led7_an_o : out  STD_LOGIC_VECTOR (3 downto 0);
           led7_seg_o : out  STD_LOGIC_VECTOR (7 downto 0));
end display;

architecture Behavioral of display is

signal led_pattern : std_logic_vector(7 downto 0);
signal led_an : std_logic_vector(3 downto 0);

begin

	led7_seg_o <= led_pattern;
	led7_an_o <= led_an;
	
	process (digit_i, rst_i, clk_i) is
		
	variable counter : Integer := 0;
	
	begin
		
		if rst_i = '1' then
			led_an <= "1111";        -- all displays turned off
		elsif rising_edge(clk_i) then
			counter := counter + 1;
			if counter = 50000 then  -- 50 MHz / 50000 = 1 kHz

				counter := 0;
				
				case (led_an) is     -- displaying 4 digits in sequence
					when "1111" =>
						led_an <= "0111";
						led_pattern <= digit_i(31 downto 24);
					when "0111" =>
						led_an <= "1011";
						led_pattern <=digit_i(23 downto 16);
					when "1011" =>
						led_an <= "1101";
						led_pattern <=digit_i(15 downto 8);
					when "1101" =>
						led_an <= "1110";
						led_pattern <=digit_i(7 downto 0);
					when "1110" =>
						led_an <= "0111";
						led_pattern <= digit_i(31 downto 24);
					when others =>
						led_an <= "1111";
				end case;
				
			end if;
		
		end if;

	end process;

end Behavioral;


