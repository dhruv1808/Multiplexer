library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity LogicalStep_Lab3_top is port (
   clkin_50		: in	std_logic;
	pb				: in	std_logic_vector(3 downto 0);	-- PB[3] = Vacation Mode, PB[2] = MC_TESTMODE, PB[1] = Window open/closed
 	sw   			: in  std_logic_vector(7 downto 0); -- The switch inputs
   leds			: out std_logic_vector(7 downto 0);	-- for displaying the switch content
   seg7_data 	: out std_logic_vector(6 downto 0); -- 7-bit outputs to a 7-segment
	seg7_char1  : out	std_logic;							-- seg7 digi selectors
	seg7_char2  : out	std_logic							-- seg7 digi selectors
	
); 
end LogicalStep_Lab3_top;

architecture Energy_Monitor of LogicalStep_Lab3_top is
--
-- Components Used
------------------------------------------------------------------- 
component vacation_mode port (
	desired_temp_in 		: in 	std_logic_vector(7 downto 4);
	vacation_mode_on		: in 	std_logic;	-- TRUE if on
	desired_temp_out		: out std_logic_vector(7 downto 4)
);
end component;

component led_setup port (
	pb							: in std_logic_vector(3 downto 0);
	AGEB, AEQB, ALEB		: in std_logic;
	leds_out					: out std_logic_vector(5 downto 0)
);
end component;


component Compx4 port (
	hex_A, hex_B : in std_logic_vector(3 downto 0);
	result       : out std_logic_vector(2 downto 0) 
);
end component;

component segment7_mux port (
	 clk        : in  std_logic := '0';
	 DIN2 		: in  std_logic_vector(6 downto 0);	
	 DIN1 		: in  std_logic_vector(6 downto 0);
	 DOUT			: out	std_logic_vector(6 downto 0);
	 DIG2			: out	std_logic;
	 DIG1			: out	std_logic
);
end component;

component SevenSegment port (
   hex	   	:  in  std_logic_vector(3 downto 0);   -- The 4 bit data to be displayed
   sevenseg 	:  out std_logic_vector(6 downto 0)    -- 7-bit outputs to a 7-segment
); 
end component;
------------------------------------------------------------------
	
	
-- Create any signals, or temporary variables to be used
	
	
	signal current_temp, desired_temp	: std_logic_vector(3 downto 0);
	signal result								: std_logic_vector(2 downto 0); -- Stores A<B, A=B, A>B
	
-- Testbench signal vars:
	
	signal AEQB, ALEB, AGEB : std_logic;  -- Outputs from Magnitude Comparator
	signal TEST_PASS 			: std_logic;
	
-- Seven Segment variables
	signal current_temp_seg, desired_temp_seg	: std_logic_vector(6 downto 0);
		
----- Here the circuit begins -----

begin
	current_temp <= sw(3 downto 0);
	DESIREDTEMP: vacation_mode port map(sw(7 downto 4), NOT(pb(3)), desired_temp);	-- Setup Desired Temp
	
   TEMPCOMP: Compx4 port map(current_temp, desired_temp, result);
	
	-- Convert to right LED outputs.
	
	ALEB <= result(2);
	AEQB <= result(1);
	AGEB <= result(0);
	
	-- Modify LED values. (NOTE: leds(6) is handled later in the code, during the testbench).
	LEDSETUP: led_setup port map(pb, AGEB, AEQB, ALEB, leds(5 downto 0));	-- Assign values for leds 5 to 0.
	leds(7) <= NOT(pb(3)); 								  -- Vacation mode.
	
-- NOTE: Switch values used in this testbench are INDEPENDENT of vacation mode 
-- (Possible mismatch may occur when vacation mode is on).	

TestBench1:
PROCESS (sw, AEQB, AGEB, ALEB, pb(2)) is
	
variable EQ_PASS, GE_PASS, LE_PASS : std_logic	:= '0';

begin
	if ((sw(3 downto 0) = sw(7 downto 4)) AND (AEQB = '1')) then
		EQ_PASS := '1';
		GE_PASS := '0';
		LE_PASS := '0';
	
	elsif ((sw(3 downto 0) >= sw(7 downto 4)) AND (AGEB = '1')) then
		EQ_PASS := '0';
		GE_PASS := '1';
		LE_PASS := '0';
		
	elsif ((sw(3 downto 0) <= sw(7 downto 4)) AND (ALEB = '1')) then
		EQ_PASS := '0';
		GE_PASS := '0';
		LE_PASS := '1';
		
	else
		EQ_PASS := '0';
		GE_PASS := '0';
		LE_PASS := '0';
	
	end if;
	
	TEST_PASS <= NOT(pb(2)) AND (EQ_PASS OR GE_PASS OR LE_PASS);	-- pb(2) used to "activate" testbench. (makes output visible).
	leds(6) <= TEST_PASS;

end process;

----- Configure and Display the digits -----
	SEG1: SevenSegment port map(current_temp, current_temp_seg);	-- Digit 2
	SEG2: SevenSegment port map(desired_temp, desired_temp_seg);	-- Digit 1

	SEGMUX: segment7_mux port map(clkin_50, current_temp_seg, desired_temp_seg, seg7_data, seg7_char2, seg7_char1);

 end Energy_Monitor;

