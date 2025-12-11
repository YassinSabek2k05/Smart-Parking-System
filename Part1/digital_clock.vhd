library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity digital_clock is
    port (
        clk,reset_n: in  STD_LOGIC; 
        seconds, minutes: out INTEGER range 0 to 59;
        hours: out INTEGER range 0 to 23
    );
end entity digital_clock;

architecture rtl of digital_clock is
    signal sec_cnt : INTEGER range 0 to 59 := 0;
    signal min_cnt : INTEGER range 0 to 59 := 0;
    signal hour_cnt: INTEGER range 0 to 23 := 0;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if reset_n = '0' then
                sec_cnt  <= 0;
                min_cnt  <= 0;
                hour_cnt <= 0;
            else
                if sec_cnt = 59 then
                    sec_cnt <= 0; 
                    
                    if min_cnt = 59 then
                        min_cnt <= 0; 
                        
                        if hour_cnt = 23 then
                            hour_cnt <= 0; 
                        else
                            hour_cnt <= hour_cnt + 1;
                        end if;
                        
                    else
                        min_cnt <= min_cnt + 1;
                    end if;
                    
                else
                    sec_cnt <= sec_cnt + 1; 
                end if;
            end if;
        end if;
    end process;

    seconds <= sec_cnt;
    minutes <= min_cnt;
    hours   <= hour_cnt;

end architecture rtl;
