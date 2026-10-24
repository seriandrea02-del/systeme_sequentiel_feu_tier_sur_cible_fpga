LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;

ENTITY top IS
	PORT ( clk : IN STD_LOGIC;
			btn_ctrl, btn_0, btn_1 : in STD_LOGIC;
			led : OUT STD_LOGIC_VECTOR (3 downto 0));
END ENTITY;

ARCHITECTURE rtl OF top IS
--signal
signal DEF_TIME : unsigned(3 Downto 0) := "1000"; --8
signal FLASH_BIT : unsigned(4 Downto 0) := "10111"; --23
signal FLASH_TIME : unsigned(1 Downto 0) := "10"; --2

signal local_led : unsigned(3 downto 0);

-- fonction clog2 
function clog2(n : natural) return natural is
  variable r : natural := 0;
  variable v : natural := n - 1;
begin
  while v > 0 loop
    v := v / 2;
    r := r + 1;
  end loop;
  return r;
end function;

signal cnt_flash : unsigned(clog2(to_integer(FLASH_TIME) + 1) - 1 downto 0);

--debounce each button using the debounce module
signal sig_ctrl, sig_0, sig_1 : STD_LOGIC;
-- ... ajouter debounce

--instanciations
component debounce is
	PORT( 
		clk : in std_logic;
		inp : in std_logic;
		outp : out std_logic;
		onup : out std_logic
	);
end component;


--Finite state machine : signal
type state_t is (IDLE, INIT, SET_TIME, COUNTDOWN, DONE);
signal state : state_t;
signal state_next : state_t;

--signal generate 1 second strobe from 100MHz
signal DIV_BY : unsigned(26 downto 0) := to_unsigned(50000000, 27);
signal stb : std_logic;
signal cnt_stb : unsigned(clog2(to_integer(DIV_BY)) - 1 downto 0);


begin

-- instanciations
deb_ctrl : debounce
	port map (
		clk => clk,
		inp => btn_ctrl,
		outp => open,
		onup => sig_ctrl
	);

deb_0 : debounce
	port map (
		clk => clk,
		inp => btn_0,
		outp => open,
		onup => sig_0
	);

deb_1 : debounce
	port map (
		clk => clk,
		inp => btn_1,
		outp => open,
		onup => sig_1
	);
	
	

led <= std_logic_vector(local_led);


--move to next FSM state
process(clk)
  begin
    if (clk'EVENT AND clk = '1') then -- rising_edge(clk)
      state <= state_next;
    end if;
  end process;
  
--generate 1 second strobe from 100MHz
process(clk)
  begin
    if (clk'EVENT AND clk = '1') then -- rising_edge(clk)
      if (cnt_stb /= DIV_BY-1) then
			stb<= '0';
			cnt_stb <= cnt_stb +1;
		else
			stb <= '1';
			cnt_stb <= (others => '0');
		end if;
    end if;
end process;

--finite state machine : behaviour
process(clk)
  begin
    if (clk'EVENT AND clk = '1') then -- rising_edge(clk)
		case state is
			when INIT =>
				local_led <= DEF_TIME;
				cnt_flash <= FLASH_TIME;
			when SET_TIME =>
				if sig_0 = '1' then
					local_led <= local_led(2 downto 0) & '0';
				elsif sig_1 = '1' then
					local_led <= local_led(2 downto 0) & '1';
				end if;
			when COUNTDOWN =>
				if stb = '1' then
					local_led <= local_led - 1;
				end if;
			when DONE =>
				local_led <= (others => std_logic(cnt_stb(to_integer(FLASH_BIT))));
				if stb = '1' then
					cnt_flash <= cnt_flash - 1;
				end if;
			when others =>
				local_led <= ( others => '0');
		end case;
    end if;
end process;

--Finite state machine : state change
process(state, sig_ctrl, local_led, cnt_flash)
	begin
		Case state is
			
			when IDLE =>
				if (sig_ctrl = '1') then
					state_next <= INIT;
				else
					state_next <= IDLE;
				end if;
				
			when INIT =>
				state_next <= SET_TIME;

			when SET_TIME =>
				if sig_ctrl = '1' then
					state_next <= COUNTDOWN;
				else
					state_next <= SET_TIME;
				end if;	
			
			when COUNTDOWN =>
				if (local_led = 0) then
					state_next <= DONE;
				else
					state_next <= COUNTDOWN;
				end if;
			
			when DONE =>
				if (cnt_flash = to_unsigned(0, cnt_flash'length)) then
					state_next <= IDLE;
				else
					state_next <= DONE;
				end if;
				
			when others => state_next <= IDLE;

		END CASE;

END PROCESS;


END ARCHITECTURE;
	 C'est celui-là le code top. C'est la version évoluée ou pas ?
