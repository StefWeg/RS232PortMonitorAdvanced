----------------------------------------------------------------------------------
-- Company: 
-- Engineer:       Aja, Stefan
-- 
-- Create Date:    12:23:27 21/12/2019
-- Design Name: 
-- Module Name:    receiver - Behavioral 
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity receiver is
	Port ( 
			clk_i : in  STD_LOGIC;
			rst_i : in  STD_LOGIC;
			RXD_i : in  STD_LOGIC;
			digit_o : out  STD_LOGIC_VECTOR (31 downto 0);
			data_o : out STD_LOGIC_VECTOR(7 downto 0);
			RXD_fin_o : out STD_LOGIC
		 );
end receiver;

architecture Behavioral of receiver is

	type state_type is (standby, start, rcv, stop);
	signal state : state_type := standby;

	-- IN: value to be displayed, OUT: led display pattern
	function hexToLed(hex : STD_LOGIC_VECTOR) return STD_LOGIC_VECTOR is
	
	begin
	
		case CONV_INTEGER(hex) is           -- 'dot' segment is not touched
			when 0  => return "0000001";
			when 1  => return "1001111";
			when 2  => return "0010010";
			when 3  => return "0000110";
			when 4  => return "1001100";
			when 5  => return "0100100";
			when 6  => return "0100000";
			when 7  => return "0001111";
			when 8  => return "0000000";
			when 9  => return "0000100";
			when 10 => return "0001000";	-- A
			when 11 => return "1100000";	-- B
			when 12 => return "0110001";	-- C
			when 13 => return "1000010";	-- D
			when 14 => return "0110000";	-- E
			when 15 => return "0111000";	-- F
			when others => return "1111111";
		end case;
		
	end function;
	
	signal digit : STD_LOGIC_VECTOR(31 downto 0) := X"FFFFFFFF";
	signal data: std_logic_vector(7 downto 0):= X"00";
	signal fin : STD_LOGIC := '0';

begin

	digit_o <= digit;
	data_o <= data;
	RXD_fin_o <= fin;


	receive : process(clk_i, rst_i, RXD_i) is
	
		variable clk_counter : Integer := 0;
		variable bits_rcvd : Integer := 0;
	
	begin
	
		if rst_i = '1' then
			digit <= X"FFFFFFFF";
			clk_counter := 0;
			bits_rcvd := 0;
			data <= X"FF";
		elsif rising_edge(clk_i) then

			fin <= '0';

			case state is                      -- 50_000_000/9600 = 5208 cycles per bit

				when standby => 
					if RXD_i = '0' then        -- detected transmission
						state <= start;
					end if;

				when start =>
					clk_counter := clk_counter + 1;
					
					if clk_counter > 2604 then -- after 2604 cycles = 1/2 bit (middle of start bit)
						clk_counter := 0;
						state <= rcv;          -- start sampling procedure
					end if;	
					
				when rcv =>
					clk_counter := clk_counter + 1;
					
					if clk_counter > 5208 then -- after 5208 cycles = 1 bit
						clk_counter := 0;
						data(bits_rcvd) <= RXD_i;  -- store new received bit
						bits_rcvd := bits_rcvd + 1;
					end if;
					if bits_rcvd = 8 then      -- 8 bits received
						bits_rcvd := 0;
						state <= stop;
					end if;
					
				when stop =>
					clk_counter := clk_counter + 1;
					if clk_counter > 5208 then -- after 5208 cycles = 1 bit (middle of end bit)
						
						clk_counter := 0;
						state <= standby;
						
						digit(15 downto 9) <= hexToLed(data(7 downto 4)); -- second digit from right side
						digit(7 downto 1) <= hexToLed(data(3 downto 0));  -- first digit from right side

						fin <= '1'; -- signal end of receival ('1' lasts only single clock cycle)
						
					end if;

				when others =>
					digit <= X"FFFFFFFF";
			
			end case;
		
		end if;
		
	
	end process;


end Behavioral;



