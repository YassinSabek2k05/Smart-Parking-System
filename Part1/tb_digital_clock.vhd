library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_digital_clock is
end entity tb_digital_clock;

architecture behavior of tb_digital_clock is

    	component digital_clock
        port (
            	clk       : in  STD_LOGIC;
            	reset_n   : in  STD_LOGIC;
		seconds   : out INTEGER range 0 to 59;
		minutes   : out INTEGER range 0 to 59;
  		hours     : out INTEGER range 0 to 23
        );
    	end component;

    	signal tb_clk     : STD_LOGIC := '0';
    	signal tb_reset_n : STD_LOGIC := '1';
    	signal tb_sec     : INTEGER;
    	signal tb_min     : INTEGER;
    	signal tb_hour    : INTEGER;

	-- 50GHz
	constant period    : time := 20 ps;
begin
    tb_clk <= not tb_clk after period / 2;

    portmap: digital_clock port map(
        clk       => tb_clk,
        reset_n   => tb_reset_n,
        seconds   => tb_sec,
        minutes   => tb_min,
        hours     => tb_hour
    );

    process
    begin
        tb_reset_n <= '1'; 
	wait for 78900 ps;

        tb_reset_n <= '0';
        wait for 60 ps;
        
        tb_reset_n <= '1';
        wait for 36000 ps;
        
        wait; 
    end process;

end architecture behavior;
