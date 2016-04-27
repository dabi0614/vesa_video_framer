-- Author: David Thach
-- Date: 2016.04.28

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY testbench IS
END testbench;
 
ARCHITECTURE behavior OF testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT video_framer
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         en : IN  std_logic;
         res_sel : IN  std_logic;
         DE : OUT  std_logic;
         HS : OUT  std_logic;
         VS : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal en : std_logic := '0';
   signal res_sel : std_logic := '0'; -- Note need to change clk_freq if mode = 1

 	--Outputs
   signal DE : std_logic;
   signal HS : std_logic;
   signal VS : std_logic;

   -- Clock period definitions
	constant clk_freq_mode0 : real := 154.0E6;
	constant clk_freq_mode1 : real := 91.0E6;
   -- constant clk_period : time := 51.948 ns;
	constant clk_period : time := 1 sec / clk_freq_mode0;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: video_framer PORT MAP (
          clk => clk,
          rst => rst,
          en => en,
          res_sel => res_sel,
          DE => DE,
          HS => HS,
          VS => VS
        );

   -- Clock process definitions
   clk_process: process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		rst <= '1';
      wait for 100 ns;
		
		rst <= '0';
		wait for clk_period*10;

      -- insert stimulus here 
		en <= '1';

      wait;
   end process;

END;
