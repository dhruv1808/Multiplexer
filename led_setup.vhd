library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity led_setup is port (
	pb							: in std_logic_vector(3 downto 0);
	AGEB, AEQB, ALEB		: in std_logic;
	leds_out					: out std_logic_vector(5 downto 0)
);
end led_setup;


architecture code of led_setup is
	signal win_door_closed 		: std_logic;


begin

	win_door_closed <= pb(1) AND pb(0); -- Door/Window both closed?
	
	leds_out(2) <= AGEB AND win_door_closed;	-- A/C ON (When windows and doors closed).
	leds_out(1) <= AEQB;								-- System at temp
	leds_out(0) <= ALEB AND win_door_closed;
	
	leds_out(3) <= (AGEB OR ALEB) AND win_door_closed; -- Blower.
	leds_out(5 downto 4) <= NOT(pb(1 downto 0)); 		  -- Window and Door status.
	
end code;