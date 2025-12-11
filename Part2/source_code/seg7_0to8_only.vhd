library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

ENTITY seg7_0to8_only IS
	port( num: in integer range 0 to 8;
			leds: out std_logic_vector(0 to 6));
end seg7_0to8_only;

architecture behavior of seg7_0to8_only is 
begin 
	process(num)
	begin
		case num is
		when 0 => leds<="0000001";
		when 1 => leds<="1001111";
		when 2 => leds<="0010010";
		when 3 => leds<="0000110";
		when 4 => leds<="1001100";
		when 5 => leds<="0100100";
		when 6 => leds<="0100000";
		when 7 => leds<="0001111";
		when 8 => leds<="0000000";
		when others=>leds<="1111100";
		end case;
	end process;
end behavior;