--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:23:14 12/21/2019
-- Design Name:   
-- Module Name:   C:/Users/stefa/Documents/ISE_Xilinx/core_gen/core_gen_tb.vhd
-- Project Name:  core_gen
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: core_gen
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY core_gen_tb IS
END core_gen_tb;
 
ARCHITECTURE behavior OF core_gen_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT core_gen
    PORT(
         clk_i : IN  std_logic;
         rst_i : IN  std_logic;
         RXD_i : IN  std_logic;
         TXD_o : OUT  std_logic;
         ld0 : OUT  std_logic;
         led7_an_o : OUT  std_logic_vector(3 downto 0);
         led7_seg_o : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk_i : std_logic := '0';
   signal rst_i : std_logic := '0';
   signal RXD_i : std_logic := '0';

 	--Outputs
   signal TXD_o : std_logic;
   signal ld0 : std_logic;
   signal led7_an_o : std_logic_vector(3 downto 0);
   signal led7_seg_o : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_i_period : time := 20 ns;  -- 50 MHz
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: core_gen PORT MAP (
          clk_i => clk_i,
          rst_i => rst_i,
          RXD_i => RXD_i,
          TXD_o => TXD_o,
          ld0 => ld0,
          led7_an_o => led7_an_o,
          led7_seg_o => led7_seg_o
        );

   -- Clock process definitions
   clk_i_process :process
   begin
		clk_i <= '0';
		wait for clk_i_period/2;
		clk_i <= '1';
		wait for clk_i_period/2;
   end process;
 

   -- Stimulus process (simulate 350 ms, change MAX_IN_ROW to 2)
   stim_proc: process
   begin		
      
		RXD_i <= '1';
		
		-- hold reset for 100 us
		rst_i <= '1';
		wait for 100 us;
		rst_i <= '0';
	
		wait for 500 us;
      
		--0x41 'A'
		RXD_i <= '0';     -- start bit
		wait for 104 us;  -- duration of bit when baudrate = 9600 bps
		RXD_i <= '1';
		wait for 104 us;
		RXD_i <= '0';
		wait for 104 us;
		RXD_i <= '0';
		wait for 104 us;
		RXD_i <= '0';
		wait for 104 us;
		RXD_i <= '0';
		wait for 104 us;
		RXD_i <= '0';
		wait for 104 us;
		RXD_i <= '1';
		wait for 104 us;
		RXD_i <= '0';
		wait for 104 us;
		RXD_i <= '1';    -- stop bit
		wait for 104 us;
		
		wait for 500 us;
		
		--0x18; (< 32: asterisk 0x2A should be used to fill patterns)
		RXD_i <= '0';     -- start bit
		wait for 104 us;  -- duration of bit when baudrate = 9600 bps
		RXD_i <= '0';
		wait for 104 us;
		RXD_i <= '0';
		wait for 104 us;
		RXD_i <= '0';
		wait for 104 us;
		RXD_i <= '1';
		wait for 104 us;
		RXD_i <= '1';
		wait for 104 us;
		RXD_i <= '0';
		wait for 104 us;
		RXD_i <= '0';
		wait for 104 us;
		RXD_i <= '0';
		wait for 104 us;
		RXD_i <= '1';    -- stop bit
		wait for 104 us;

      wait;
   end process;

END;
