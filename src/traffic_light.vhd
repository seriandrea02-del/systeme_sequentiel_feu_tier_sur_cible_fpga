library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity traffic_light is
    port (
        clk : in  std_logic;

        main_rouge  : out std_logic;
        main_orange : out std_logic;
        main_vert   : out std_logic;

        side_rouge  : out std_logic;
        side_orange : out std_logic;
        side_vert   : out std_logic
    );
end entity traffic_light;

architecture light of traffic_light is

    constant T_RED         : integer := 1;	-- 1 s de feux rouges
    constant T_RED_ORANGE  : integer := 1;	-- 1 s de rouge + orange avant le vert
    constant T_GREEN_MAIN  : integer := 10;	-- 10 s de vert sur la route main
    constant T_GREEN_SIDE  : integer := 5;	-- 5 s de vert sur la route secon
    constant T_ORANGE      : integer := 2;	-- 2 s d'orange après le vert

    constant CLK_FREQ : integer := 50_000_000;
    constant DIV_BY   : integer := CLK_FREQ;	

    type state_t is (IDLE, INIT, RED, RED_ORANGE, GREEN, ORANGE);
    signal state     : state_t := IDLE;

    signal cnt_phase : integer range 0 to 31 := 0;

    signal light_set : std_logic := '0';	-- light_set = '0' '1': route principale /secon

    signal stb       : std_logic := '0';	-- qd = '1', cad 1s
    signal cnt_stb   : integer range 0 to DIV_BY := 0; -- il revient 0 qd div jus a 49M

begin

    process(clk)	-- decompter jusa 0 => stb = '1'
    begin
        if rising_edge(clk) then
            if cnt_stb = DIV_BY - 1 then
                cnt_stb <= 0;
                stb     <= '1';
            else
                cnt_stb <= cnt_stb + 1;
                stb     <= '0';
            end if;
        end if;
    end process;

    process(clk)	-- machine d'etat
    begin
        if rising_edge(clk) then
            if (state /= IDLE and state /= INIT) and stb = '1' then --qd std egale 1 seconde cntp - 1
                if cnt_phase > 0 then
                    cnt_phase <= cnt_phase - 1;	-- cntp pour compter le temps
                end if;
            end if;

            case state is
                when IDLE =>
                    state <= INIT;

                when INIT =>
                    state     <= RED;
                    cnt_phase <= T_RED;	--tred 1s
                    light_set <= '0';  -- commence par la route principale

                when RED =>
                    if cnt_phase = 0 and stb = '1' then	
                        state     <= RED_ORANGE;	--qd tred fini, on entre la prochaine etat
                        cnt_phase <= T_RED_ORANGE;	--ajouter le temps de tredorange
                    end if;

                when RED_ORANGE =>
                    if cnt_phase = 0 and stb = '1' then
                        state <= GREEN;
                        if light_set = '1' then
                            cnt_phase <= T_GREEN_SIDE;  -- route secondaire
                        else
                            cnt_phase <= T_GREEN_MAIN;  -- route principale
                        end if;
                    end if;

                when GREEN =>
                    if cnt_phase = 0 and stb = '1' then
                        state     <= ORANGE;
                        cnt_phase <= T_ORANGE;
                    end if;

                when ORANGE =>
                    if cnt_phase = 0 and stb = '1' then
                        state     <= RED;
                        cnt_phase <= T_RED;
                        light_set <= not light_set;  -- on change de route
                    end if;

                when others =>
                    state <= IDLE;
            end case;
        end if;
    end process;

    process(state, light_set)	--mettre les etat des led
    begin
        main_rouge  <= '1';	--par defaut
        main_orange <= '0';
        main_vert   <= '0';

        side_rouge  <= '1';
        side_orange <= '0';
        side_vert   <= '0';

        case state is
            when RED =>
                null;	-- la mm situation que par defaut
					 
            when RED_ORANGE =>
                if light_set = '0' then
                    main_rouge  <= '1';
                    main_orange <= '1';
                    main_vert   <= '0';

                    side_rouge  <= '1';
                    side_orange <= '0';
                    side_vert   <= '0';
                else
                    side_rouge  <= '1';
                    side_orange <= '1';
                    side_vert   <= '0';

                    main_rouge  <= '1';
                    main_orange <= '0';
                    main_vert   <= '0';
                end if;

            when GREEN =>
                if light_set = '0' then
                    main_rouge  <= '0';
                    main_orange <= '0';
                    main_vert   <= '1';

                    side_rouge  <= '1';
                    side_orange <= '0';
                    side_vert   <= '0';
                else
                    side_rouge  <= '0';
                    side_orange <= '0';
                    side_vert   <= '1';

                    main_rouge  <= '1';
                    main_orange <= '0';
                    main_vert   <= '0';
                end if;
					 
            when ORANGE =>
                if light_set = '0' then
                    main_rouge  <= '0';
                    main_orange <= '1';
                    main_vert   <= '0';

                    side_rouge  <= '1';
                    side_orange <= '0';
                    side_vert   <= '0';
                else
                    side_rouge  <= '0';
                    side_orange <= '1';
                    side_vert   <= '0';

                    main_rouge  <= '1';
                    main_orange <= '0';
                    main_vert   <= '0';
                end if;

            when others =>
                null;
        end case;
    end process;

end architecture light;

