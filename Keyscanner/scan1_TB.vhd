---------------------------------------------------------------------------------------------------
--
-- Title       : Test Bench for scan1
-- Design      : scan1
-- Author      : kls
-- Company     : 
--
---------------------------------------------------------------------------------------------------
--
-- File        : $DSN\src\TestBench\scan1_TB.vhd
-- Generated   : 3/21/15, 11:59 AM
-- From        : $DSN\src\scan1.vhd
-- By          : Active-HDL Built-in Test Bench Generator
--
---------------------------------------------------------------------------------------------------
--
-- Description : Testbench for scan1. This testbench instantiates the UUT and a model of the keypad
-- to which the UUT is connected. Processes are used to generate the reset signal and a square
-- wave system clock. Since the clock never stops, you must set a RUN FOR value before starting a
-- simulation run. A third process monitors the keypad scanner output and compares it whti the key
-- press being simulated. Simulated key presses are generated by a projected waveform concurrent
-- signal assignment statement.
--
---------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity scan1_tb is
end scan1_tb;

architecture tb_architecture of scan1_tb is
	
	-- Stimulus signals
	signal clk : std_logic;
	signal rst_bar : std_logic;
	signal col_input : std_logic_vector(4 downto 0);
	-- Observed signals
	signal row_out : std_logic_vector(3 downto 0);
	signal key_code : std_logic_vector(4 downto 0);
	signal key_num_sig : integer range 0 to 20;
	signal key_num_bin_sig : std_logic_vector(4 downto 0);
	signal kp_bar : std_logic;
	
	-- Key values to be entered during simulation.
	constant key1 : integer := 4;
	constant key2	: integer := 7;
	constant key3 : integer := 18;
	constant key4 : integer := 11;
	constant nkey : integer := 20;	-- no key pressed value, do not change
	
	constant	period : time := 125 ns;	-- 8MHz clock
	
begin
	
	-- Unit Under Test port map
	UUT : entity scan1
	port map (
		clk => clk,
		rst_bar => rst_bar,
		col_input => col_input,
		row_out => row_out,
		key_code => key_code,
		kp_bar => kp_bar
		);
	
	-- Model of 4 x 5 matrix keypad. models keypad output in response to
	-- its being scanned.
	keypad_mod: entity keypad
	port map (
		row_in => row_out,
		key_num => key_num_sig,
		col_out => col_input,
		key_num_bin => key_num_bin_sig
		);
	
	-- Keypress simulation using projected waveform. Values of constants key1, key2,
	--	key3 and key4 can be changed to simulate a different key sequence.
	-- This could have been done interactively with a value stimulator, but would
	-- be more tedious
	key_num_sig <= nkey, key1 after 1ms, nkey after 1.05ms, key2 after 2ms, nkey after 2.05ms,
	key3 after 3ms, nkey after 3.05ms, key4 after 4.0ms, nkey after 4.05ms;
	
	-- Monitor
	monitor: process
	begin	
		wait on kp_bar until kp_bar = '0';
		wait for 20 * period;
		assert key_num_sig = to_integer(unsigned(key_code))
		report "Error: key_code is for key " & integer'image(to_integer(unsigned(key_code))) &
		"should be for key " & integer'image(key_num_sig)
		severity error;
	end process;	
	
	-- System clock runs forever, set RUN FOR limit before simulation run
	clock_gen: process
	begin
		clk <= '0';				-- clock starts at 0
		wait for period/2;	-- square wave clock
		loop
			clk <= not clk;
			wait for period/2;
		end loop;				-- runs forever
	end process;
	
	-- System reset
	reset: process
	begin
		rst_bar <= '0';		-- active low reset
		for i in 1 to 2 loop	-- duration 1.5 clock periods
			wait on clk until clk = '1';
		end loop;
		rst_bar <= '1';
		wait;
	end process;
	
end tb_architecture;


