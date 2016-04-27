-- Author: David Thach
-- Date: 2016.04.28

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY top_testbench IS
END top_testbench;

ARCHITECTURE behavior OF top_testbench IS 

  -- Component Declaration
	COMPONENT top_video_framer
	PORT(
		clk_in : in  STD_LOGIC;
		rst : in  STD_LOGIC;
		en : in  STD_LOGIC;
		res_sel : in  STD_LOGIC;
		clk_out : out  STD_LOGIC;
		DE : out  STD_LOGIC;
		HS : out  STD_LOGIC;
		VS : out  STD_LOGIC;
		RGB : out  STD_LOGIC_VECTOR (23 downto 0)
		);
	END COMPONENT;

	-- Inputs
	SIGNAL clk_in : STD_LOGIC := '0';
	SIGNAL rst : STD_LOGIC := '0';
	SIGNAL en : STD_LOGIC := '0';
	SIGNAL res_sel : STD_LOGIC := '0'; -- Note need to change clk_freq if mode = 1
	
	-- Outputs
	SIGNAL clk_out : STD_LOGIC;
	SIGNAL DE : STD_LOGIC;
	SIGNAL HS : STD_LOGIC;
	SIGNAL VS : STD_LOGIC;
	SIGNAL RGB : STD_LOGIC_VECTOR (23 downto 0);
	
	-- Clock period definitions
	constant clk_freq_mode0 : real := 154.0E6;
	constant clk_freq_mode1 : real := 91.0E6;
   -- constant clk_period : time := 51.948 ns;
	constant clk_period : time := 1 sec / clk_freq_mode0;
	
BEGIN
	-- Component Instantiation
	uut:  top_video_framer PORT MAP(
		clk_in => clk_in,
		rst => rst,
		en => en,
		res_sel => res_sel,
		clk_out => clk_out,
		DE => DE,
		HS => HS,
		VS => VS,
		RGB => RGB
	);

   -- Clock process definitions
   clk_process: process
   begin
		clk_in <= '0';
		wait for clk_period/2;
		clk_in <= '1';
		wait for clk_period/2;
   end process;

	--  Test Bench Statements
	tb : PROCESS
	BEGIN
		-- hold reset state for 100 ns.
		rst <= '1';
		wait for 100 ns; -- wait until global set/reset completes

		-- Add user defined stimulus here		
		rst <= '0';
		wait for clk_period*10;
		
		en <= '1';
		wait; -- will wait forever
	END PROCESS tb;
--  End Test Bench 

	END;
