----------------------------------------------------------------------------------
-- Company: 
-- Engineer:       Aja, Stefan
-- 
-- Create Date:    10:50:42 21/12/2019 
-- Design Name: 
-- Module Name:    core_gen - Behavioral 
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity core_gen is
Port ( clk_i : in STD_LOGIC;
       rst_i : in STD_LOGIC;
       RXD_i : in STD_LOGIC;
       TXD_o : out  STD_LOGIC;
	    ld0 : out  STD_LOGIC;
       led7_an_o : out  STD_LOGIC_VECTOR (3 downto 0);
       led7_seg_o : out  STD_LOGIC_VECTOR (7 downto 0));
end core_gen;

architecture Structural of core_gen is

	component char_mem
		port (
		clka: in std_logic;
		addra: in std_logic_vector(11 downto 0);
		douta: out std_logic_vector(7 downto 0));
	end component;

	component fifo_mem
		port (
		clk: in std_logic;
		rst: in std_logic;
		din: in std_logic_vector(7 downto 0);
		wr_en: in std_logic;
		rd_en: in std_logic;
		dout: out std_logic_vector(7 downto 0);
		full: out std_logic;
		empty: out std_logic);
	end component;
	
	component transmitter is
		Port (
		clk_i : in STD_LOGIC;
		rst_i : in STD_LOGIC;
		data_i : in STD_LOGIC_VECTOR(7 downto 0);
		TXD_enable_i : in  STD_LOGIC; -- transmission activation
		TXD_is_ongoing_o : out STD_LOGIC;
		TXD_o : out STD_LOGIC );
	end component;
	
	component receiver is
	Port ( 
			clk_i : in  STD_LOGIC;
			rst_i : in  STD_LOGIC;
			RXD_i : in  STD_LOGIC;
			digit_o : out  STD_LOGIC_VECTOR (31 downto 0);
			data_o : out STD_LOGIC_VECTOR(7 downto 0);
			RXD_fin_o : out STD_LOGIC
		);
	end component;
	
	component display is
    Port ( clk_i : in  STD_LOGIC;
           rst_i : in  STD_LOGIC;
           digit_i : in  STD_LOGIC_VECTOR (31 downto 0);
           led7_an_o : out  STD_LOGIC_VECTOR (3 downto 0);
           led7_seg_o : out  STD_LOGIC_VECTOR (7 downto 0));
	end component;
	
	constant MAX_IN_ROW : Integer := 8;
	
	-- RXD/TXD signal
	
	signal t_digit_o : STD_LOGIC_VECTOR(31 downto 0);
	
	-- RXD signals
	
	signal t_data_RXD : STD_LOGIC_VECTOR(7 downto 0) := X"FF";
	signal t_RXD_fin_o : STD_LOGIC := '0';
	
	-- TXD signals
	
	signal TXD_enable : std_logic := '0';
	signal TXD_working : std_logic;
	signal t_data_TXD : STD_LOGIC_VECTOR(7 downto 0) := X"FF";
	
	-- FIFO signals
	
	signal rd_enable : std_logic := '0';
	signal wr_enable : std_logic := '0';
	signal fifo_in :std_logic_vector (7 downto 0);
	signal fifo_out : std_logic_vector (7 downto 0);
	
	-- ROM signals
	
	signal mem_addr : std_logic_vector (11 downto 0);
	signal mem_out : std_logic_vector (7 downto 0);

	-- buffer dla TXD (contains line to send) 

	type my_array is array (MAX_IN_ROW - 1 downto 0) of std_logic_vector(7 downto 0);
	signal rtt : my_array;
	SHARED variable rtt_cnt : Integer := 0;

	-- sending states
	
	signal ascii_code : STD_LOGIC_VECTOR(7 downto 0) := X"00";
	
	SHARED variable ascii_num : Integer := 0; -- currently processed ascii
	SHARED variable ascii_row : Integer := 0; -- row of response 'picture'
	SHARED variable ascii_bit : Integer := 0; -- bit in pattern associated with current ascii and row
	
	SHARED variable chars_received : Integer := 0;

	-- transmitter states
	type t_state is (standby, transmit, dequeue);
	signal TXD_state : t_state := standby;
	signal TXD_next_state : t_state := standby;
	
	signal empty : STD_LOGIC := '0';
		
	begin
	
	-- mapping definitions
	ROM : char_mem port map (
		clka => clk_i,
		addra => mem_addr,
		douta => mem_out);

	FIFO : fifo_mem port map (
		clk => clk_i,
		rst => rst_i,
		din => fifo_in,
		wr_en => wr_enable,
		rd_en => rd_enable,
		dout => fifo_out,
		full => ld0,
		empty => empty);

	RXD : receiver port map (
		clk_i => clk_i,
		rst_i => rst_i,
		RXD_i => RXD_i,
		digit_o => t_digit_o,
		data_o => t_data_RXD,
		RXD_fin_o => t_RXD_fin_o);

	TXD : transmitter port map (
		clk_i => clk_i,
		rst_i => rst_i,
		data_i => t_data_TXD,
		TXD_enable_i => TXD_enable,
		TXD_is_ongoing_o => TXD_working,
		TXD_o => TXD_o);

	DISP : display port map (
		clk_i => clk_i,
		rst_i => rst_i,
		digit_i => t_digit_o,
		led7_an_o => led7_an_o,
		led7_seg_o => led7_seg_o);
		
	
	-- main logic
	main_logic : process (clk_i, rst_i) is
	
	begin
		if rst_i = '1' then
				TXD_enable <= '0';
				TXD_next_state <= standby;
				wr_enable <= '0';
				rd_enable <= '0';
				
				
		elsif rising_edge(clk_i) then
			
			-- memory address = (ascii * 16) + row index
			if ascii_num < MAX_IN_ROW then
				mem_addr(11 downto 4) <= rtt(ascii_num)(7 downto 0);
			end if;
			if ascii_num < 16 then
				mem_addr(3 downto 0) <= CONV_STD_LOGIC_VECTOR(ascii_row, 4);
			end if;
			
			-- ascii used for pattern filling
			if ascii_num < MAX_IN_ROW then
				if CONV_INTEGER(rtt(ascii_num)(7 downto 0)) >= 32 then
					ascii_code <= rtt(ascii_num)(7 downto 0);
				else
					ascii_code <= X"2A"; -- asterisk 0x2A
				end if;
			end if;
			
			TXD_state <= TXD_next_state;
			
			wr_enable <= '0';
			rd_enable <= '0';
			TXD_enable <= '0';  -- don't send (by default)
					
			-- if whole byte was received, write it to FIFO
			if t_RXD_fin_o = '1' and wr_enable = '0' then   -- info: fin '1' lasts only single clock cycle
				wr_enable <= '1';
				fifo_in <= t_data_RXD;
				chars_received := chars_received + 1;
			else
			
			case TXD_state is

				when standby =>
				
					if chars_received > MAX_IN_ROW - 1 then -- received full line of chars...
						
						rd_enable <= '1';                   -- ...start reading from FIFO
						rtt_cnt := 0;
						
						TXD_next_state <= dequeue;
					
					end if;
				
				when dequeue =>
					
						if rtt_cnt < MAX_IN_ROW then
						
							rtt(rtt_cnt)(7 downto 0) <= fifo_out; -- write fifo output to line buffer
							
							if rtt_cnt < MAX_IN_ROW-2 then
							
								rd_enable <= '1';                  -- sustain read enable for MAX_IN_ROW-1 more cycles
								
							else                                  -- when MAX_IN_ROW clock cycles passes...
							
								ascii_num := 0;
								ascii_row := 0;
								ascii_bit := 0;
								TXD_next_state <= transmit;        -- ...begin transmission of response
								
							end if;
							
							rtt_cnt := rtt_cnt + 1;
							
						end if;
					
				when transmit =>

					if ascii_row = 16 then               -- all rows of response were sent...
					
						chars_received := chars_received - MAX_IN_ROW; -- subtract already processed chars
						
						TXD_next_state <= standby;           -- ...stop transmission
					
					elsif TXD_working = '0' and TXD_enable = '0' then  -- transmitter is not occupied

						if ascii_num = MAX_IN_ROW then       -- when all ascii in row were processed...
						
							if t_data_TXD /= X"0D" then      -- send CR (if it hasn't been already)
								
								TXD_enable <= '1';
								t_data_TXD <= X"0D";
								
							else 
							
								TXD_enable <= '1';           -- send LF
								t_data_TXD <= X"0A";

								ascii_num := 0;
								ascii_row := ascii_row + 1;  -- ...go to next row
							
							end if;
							
						else                                 -- processing all ascii in row...
							
							TXD_enable <= '1';
							
							-- reading pattern from ROM memory
							-- | >> address was determined in previous cycle:                   << |
							-- | >> ascii_num and ascii_row are known at least one cycle before << |
							case mem_out(7 - ascii_bit) is   -- extracting proper bit from pattern
								when '1' => t_data_TXD <= ascii_code;
								when '0' => t_data_TXD <= X"20";
								when others => t_data_TXD <= X"00";
							end case;
							
							ascii_bit := ascii_bit + 1;
							
							if ascii_bit = 8 then            -- when processed whole pattern...
								ascii_bit := 0;
								ascii_num := ascii_num + 1;  -- ...move to another ascii in row
							end if;
							
						end if;

					end if;

			end case;
			
			end if;
		
		end if;
	
	end process;
	
end architecture Structural;

