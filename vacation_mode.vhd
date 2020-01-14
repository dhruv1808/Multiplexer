library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity vacation_mode is port (
	desired_temp_in 		: in 	std_logic_vector(7 downto 4);
	vacation_mode_on		: in 	std_logic;	-- TRUE if on
	desired_temp_out		: out std_logic_vector(7 downto 4)
);
end vacation_mode;


architecture code of vacation_mode is 

begin

-- Set value of desired temp depending on vacation mode [pb(3)]
	with vacation_mode_on select
		desired_temp_out <= desired_temp_in when '0',
							     "0100" when '1';

end code;