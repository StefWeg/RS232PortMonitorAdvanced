--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:56:44 12/21/2019
-- Design Name:   
-- Module Name:   C:/Users/stefa/Documents/ISE_Xilinx/core_gen/transmitter_tb.vhd
-- Project Name:  core_gen
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: transmitter
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
 
ENTITY transmitter_tb IS
END transmitter_tb;
 
ARCHITECTURE behavior OF transmitter_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT transmitter
    PORT(
         clk_i : IN  std_logic;
         rst_i : IN  std_logic;
         data_i : IN  std_logic_vector(7 downto 0);
         TXD_enable_i : IN  std_logic;
         TXD_is_ongoing_o : OUT  std_logic;
         TXD_o : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk_i : std_logic := '0';
   signal rst_i : std_logic := '0';
   signal data_i : std_logic_vector(7 downto 0) := (others => '0');
   signal TXD_enable_i : std_logic := '0';

 	--Outputs
   signal TXD_is_ongoing_o : std_logic;
   signal TXD_o : std_logic;

   -- Clock period definitions
   constant clk_i_period : time := 20 ns;  -- 50 MHz
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: transmitter PORT MAP (
          clk_i => clk_i,
          rst_i => rst_i,
          data_i => data_i,
          TXD_enable_i => TXD_enable_i,
          TXD_is_ongoing_o => TXD_is_ongoing_o,
          TXD_o => TXD_o
        );

   -- Clock process definitions
   clk_i_process :process
   begin
		clk_i <= '0';
		wait for clk_i_period/2;
		clk_i <= '1';
		wait for clk_i_period/2;
   end process;
 

   -- Stimulus process (simulate 2 ms)
   stim_proc: process
   begin
		
		-- hold reset for 100 us
		rst_i <= '1';
		wait for 100 us;
		rst_i <= '0';
	
		wait for 500 us;
		
		data_i <= X"39";
		TXD_enable_i <= '1';
      wait for clk_i_period; -- disable TXD_enable after single clock cycle
		TXD_enable_i <= '0';

      wait;
   end process;

END;
