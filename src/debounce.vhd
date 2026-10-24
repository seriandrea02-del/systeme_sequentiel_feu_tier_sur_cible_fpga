LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;

ENTITY debounce IS
	PORT( 
		clk : in std_logic;
		inp : in std_logic;
		outp : out std_logic;
		onup : out std_logic
	);
END ENTITY debounce;

ARCHITECTURE rtl OF debounce IS
--signal
signal sync_0 , sync_1 : std_logic;

signal cnt : unsigned(19 downto 0); -- 2^20 = 10ms counter at 100MHz
signal idle, max : std_logic;

signal local_outp : std_logic;

begin
	
process(clk)
  begin
    if (clk'EVENT AND clk = '1') then -- rising_edge(clk)
      sync_0 <= inp;
		sync_1 <= sync_0;
    end if;
  end process;

process(clk)
  begin
    if (clk'EVENT AND clk = '1') then -- rising_edge(clk)
		if idle = '1' then
			cnt <= (others =>'0');
		else
			cnt <= cnt + 1 ;
			if max = '1' then
				local_outp <= not(local_outp);
			end if;
		end if;
    end if;
  end process;

outp <= local_outp;
  
idle <= '1' when local_outp = sync_1 else '0';
max <= '1' when cnt = (cnt'range => '1') else '0';
onup <= not(idle) and max and local_outp;
  
END ARCHITECTURE rtl;
