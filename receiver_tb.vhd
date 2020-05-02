--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:44:14 12/21/2019
-- Design Name:   
-- Module Name:   C:/Users/stefa/Documents/ISE_Xilinx/core_gen/receiver_tb.vhd
-- Project Name:  core_gen
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: receiver
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
 
ENTITY receiver_tb IS
END receiver_tb;
 
ARCHITECTURE behavior OF receiver_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT receiver
    PORT(
         clk_i : IN  std_logic;
         rst_i : IN  std_logic;
         RXD_i : IN  std_logic;
         digit_o : OUT  std_logic_vector(31 downto 0);
         data_o : OUT  std_logic_vector(7 downto 0);
         RXD_fin_o : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk_i : std_logic := '0';
   signal rst_i : std_logic := '0';
   signal RXD_i : std_logic := '0';

 	--Outputs
   signal digit_o : std_logic_vector(31 downto 0);
   signal data_o : std_logic_vector(7 downto 0);
   signal RXD_fin_o : std_logic;

   -- Clock period definitions
   constant clk_i_period : time := 20 ns;  -- 50 MHz
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: receiver PORT MAP (
          clk_i => clk_i,
          rst_i => rst_i,
          RXD_i => RXD_i,
          digit_o => digit_o,
          data_o => data_o,
          RXD_fin_o => RXD_fin_o
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

		RXD_i <= '1';
		
		-- hold reset for 100 us
		rst_i <= '1';
		wait for 100 us;
		rst_i <= '0';
	
		wait for 500 us;
      
		--0x39
		RXD_i <= '0';     -- start bit
		wait for 104 us;  -- duration of bit when baudrate = 9600 bps
		RXD_i <= '1';
		wait for 104 us;
		RXD_i <= '0';
		wait for 104 us;
		RXD_i <= '0';
		wait for 104 us;
		RXD_i <= '1';
		wait for 104 us;
		RXD_i <= '1';
		wait for 104 us;
		RXD_i <= '1';
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
