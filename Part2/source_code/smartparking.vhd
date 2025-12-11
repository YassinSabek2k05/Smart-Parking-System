library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity smartparking is
    port (
        clk,reset,btn_toggle,arduino_in: in  STD_LOGIC;                                     
        ir      : in  STD_LOGIC_VECTOR(1 downto 0); 
        mode    : in  STD_LOGIC := '0';-- 0=Auto, 1=Manual
        pwm_out,buzzer_out : out STD_LOGIC;
        disp0,disp1   : out STD_LOGIC_VECTOR(0 to 6)
    );
end entity smartparking;

architecture rtl of smartparking is

    component seg7_0to8_only 
        port( num : integer range 0 to 8; leds : out std_logic_vector(0 to 6) );
    end component;

    constant PWM_PERIOD : INTEGER := 1_000_000;
    constant GATE_OPEN  : INTEGER :=  50_000;
    constant GATE_CLOSED: INTEGER := 100_000;
    
    -- INCREASED DEBOUNCE: 50ms (Very stable)
    constant DEBOUNCE_LIMIT : INTEGER := 2_500_000; 

    signal counter             : INTEGER range 0 to PWM_PERIOD - 1 := 0;
    signal current_pulse_width : INTEGER range 0 to PWM_PERIOD := GATE_CLOSED;
    signal parking             : INTEGER range 0 to 8 := 8;
    signal mode_int            : INTEGER range 0 to 1;

    -- Debounce Signals
    signal ir_stable     : STD_LOGIC_VECTOR(1 downto 0) := "11";
    signal ir_cnt        : INTEGER range 0 to DEBOUNCE_LIMIT := 0;
    signal ir_candidate  : STD_LOGIC_VECTOR(1 downto 0) := "11";

    signal btn_stable    : STD_LOGIC := '1';
    signal btn_cnt       : INTEGER range 0 to DEBOUNCE_LIMIT := 0;
    signal btn_candidate : STD_LOGIC := '1';
    type t_auto_state is (WAITING, ENTERING, EXITING, WAIT_FOR_CLEAR);
    signal state : t_auto_state := WAITING;

    type t_manual_state is (M_WAIT_PRESS, M_ACTION, M_WAIT_RELEASE);
    signal m_state : t_manual_state := M_WAIT_PRESS;
    
    signal manual_open : STD_LOGIC := '0';

begin
   mode_int <= 1 when mode = '1' else 0;
	--bonus
	buzzer_out <= arduino_in;
	
   parkingDisplay: seg7_0to8_only port map( num => parking,  leds => disp0 );
   modedisplay:    seg7_0to8_only port map( num => mode_int, leds => disp1 );
    
    process(clk)
    begin
			if rising_edge(clk) then
            if ir /= ir_candidate then --ir debouncer
                ir_candidate <= ir;
                ir_cnt       <= 0;
            elsif ir_cnt < DEBOUNCE_LIMIT then
                ir_cnt <= ir_cnt + 1;
            else
                ir_stable <= ir_candidate; 
            end if;

            if btn_toggle /= btn_candidate then --button debouncer
                btn_candidate <= btn_toggle;
                btn_cnt       <= 0;
            elsif btn_cnt < DEBOUNCE_LIMIT then
                btn_cnt <= btn_cnt + 1;
            else
                btn_stable <= btn_candidate;
            end if;

            if reset = '0' then
                parking             <= 8;
                current_pulse_width <= GATE_CLOSED;
                counter             <= 0;
                
                state       <= WAITING;
                m_state     <= M_WAIT_PRESS;
                manual_open <= '0';
            else
                
                case mode_int is
                    when 0 => -- AUTO MODE
                        manual_open <= '0'; 
                        m_state     <= M_WAIT_PRESS; -- Reset Manual State
                        
                        -- (Auto Logic - Works Correctly)
                        case state is
                            when WAITING =>
                                current_pulse_width <= GATE_CLOSED;
                                if ir_stable = "01" and parking > 0 then
                                    state <= ENTERING;
                                elsif ir_stable = "10" and parking < 8 then
                                    state <= EXITING;
                                end if;
                            when ENTERING =>
                                current_pulse_width <= GATE_OPEN;
                                if ir_stable = "10" then
                                    if parking > 0 then parking <= parking - 1; end if;
                                    state <= WAIT_FOR_CLEAR;
                                elsif ir_stable = "11" then state <= WAITING; end if;
                            when EXITING =>
                                current_pulse_width <= GATE_OPEN;
                                if ir_stable = "01" then
                                    if parking < 8 then parking <= parking + 1; end if;
                                    state <= WAIT_FOR_CLEAR;
                                elsif ir_stable = "11" then state <= WAITING; end if;
                            when WAIT_FOR_CLEAR =>
                                current_pulse_width <= GATE_OPEN;
                                if ir_stable = "11" then state <= WAITING; end if;
                        end case;

                    when 1 => -- MANUAL MODE
                        state <= WAITING; 

                        -- MANUAL STATE MACHINE (Prevents Double Trigger)
                        case m_state is
                            
                            -- Step 1: Wait for Button Press ('0')
                            when M_WAIT_PRESS =>
                                if btn_stable = '0' then
                                    m_state <= M_ACTION;
                                end if;

                            -- Step 2: Do the Action ONCE
                            when M_ACTION =>
                                if manual_open = '0' then
                                    manual_open <= '1'; -- Open
                                else
                                    manual_open <= '0'; -- Close
                                    -- DECREMENT CHECK
                                    -- Only decrement if we are actually closing
                                    if parking > 0 then
                                        parking <= parking - 1;
                                    end if;
                                end if;
                                m_state <= M_WAIT_RELEASE; -- Move immediately to lock

                            -- Step 3: Wait for Button Release ('1')
                            -- We stay here until you completely let go.
                            when M_WAIT_RELEASE =>
                                if btn_stable = '1' then
                                    m_state <= M_WAIT_PRESS; -- Ready for next cycle
                                end if;
                        end case;

                        -- Apply Gate Logic based on flag
                        if manual_open = '1' and parking>0 then
                            current_pulse_width <= GATE_OPEN;
                        else
                            current_pulse_width <= GATE_CLOSED;
                        end if;

                    when others =>
                        current_pulse_width <= GATE_CLOSED;
                end case;
					if arduino_in = '1' then
                    current_pulse_width <= GATE_OPEN;
               end if;
               if counter < PWM_PERIOD - 1 then
						counter <= counter + 1;
               else
                    counter <= 0;
                end if;
                
                if counter < current_pulse_width then
                    pwm_out <= '1';
                else
                    pwm_out <= '0';
                end if;

            end if;
        end if;
    end process;

end architecture rtl;