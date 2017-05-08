library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity edge_detector is
  port (clk, bt_in: in std_logic;
			bt_out: out std_logic:= '0');
end edge_detector;

architecture Behavioral of edge_detector is
  type state_type is (s0, s1);
  signal state : state_type := s0;
   begin
		process (clk)
			begin
			 if rising_edge(clk) then
				case state is
					when s0 => 
						if bt_in = '1' then
							state <= s1;
							bt_out <= '1';
						else
							state <= s0;
							bt_out <= '1';
						end if;
					when s1 =>
						if bt_in = '1' then
							state <= s1;
							bt_out <= '1';
						else
							state <= s0;
							bt_out <= '0';
						end if;
					end case;
				end if;
			end process;
	end Behavioral;		


