----------------------------------------------------------------------------------
-- Company: 
-- Engineer:       Aja, Stefan
-- 
-- Create Date:    13:07:29 21/12/2019 
-- Design Name: 
-- Module Name:    transmitter - Behavioral 
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

entity transmitter is
	Port (
		clk_i : in STD_LOGIC;
		rst_i : in STD_LOGIC;
		data_i : in STD_LOGIC_VECTOR(7 downto 0);
		
		TXD_enable_i : in  STD_LOGIC;      -- transmission activation
		TXD_is_ongoing_o : out STD_LOGIC;  -- transmission is on-going
		
		TXD_o : out STD_LOGIC );

end transmitter;

architecture Behavioral of transmitter is

	type state_type is (standby, sending);
	signal state : state_type := standby;
	
	signal sending_bit : STD_LOGIC := '1';
	signal bits_transmitted : Integer := 0;
	
	signal counter : Integer := 0;
	
	signal is_ongoing : STD_LOGIC := '0';

begin

	TXD_o <= sending_bit;
	TXD_is_ongoing_o <= is_ongoing;

	send : process (clk_i, rst_i) is
	
	begin
	
		if rst_i = '1' then
			state <= standby;
			sending_bit <= '1';
		elsif rising_edge(clk_i) then
		
			case state is                        -- 50_000_000/9600 = 5208 cycles per bit

				when standby =>
					if TXD_enable_i = '1' and is_ongoing = '0' then
						
						is_ongoing <= '1';			
						sending_bit <= '0';         -- start bit
						counter <= 0;
						bits_transmitted <= 0;
						
						state <= sending;           -- begin sending sequence
							
					elsif counter < 10418 then      -- wait 10417 cycles = 2 bit (after end of transmission)
						counter <= counter + 1;     -- (stop bit is lasting 2 bits)
					else 
						is_ongoing <= '0';          -- inform about the end of transmission
					end if;

				when sending =>
					if counter < 5209 then          -- wait 5208 cycles = 1 bit
						counter <= counter + 1;
					elsif bits_transmitted < 8 then -- when not all bits have been transmitted yet
						counter <= 0;
						sending_bit <= data_i(bits_transmitted);  -- transmit another bit
						bits_transmitted <= bits_transmitted + 1;
					else                            -- all bits have been already transmitted
						
						sending_bit <= '1';         -- stop bit (leaving '1' for idle state)
						counter <= 0;
						
						state <= standby;
					end if;	
				
			end case;
			
		end if;

	end process send;


end Behavioral;


