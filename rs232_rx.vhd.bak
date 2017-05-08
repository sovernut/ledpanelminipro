library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
entity rs232_rx is
	generic(
		system_speed : integer := 50e6;
		baudrate : integer := 9600);
	port(
		clk_i : in std_logic;
		rst_i : in std_logic;
		req_o : out std_logic := '0';
		data_o : out std_logic_vector(7 downto 0);
		rx : in std_logic);
end rs232_rx;

architecture behave of rs232_rx is
	constant max_counter: integer := (system_speed / baudrate);
	type state_type is (
		wait_for_rx_start,
		wait_half_bit,
		receive_bits,
		wait_for_stop_bit);
	
	signal state : state_type := wait_for_rx_start;
	signal baudrate_counter : integer range 0 to max_counter := 0;
	signal bit_counter : integer range 0 to 7 := 0;
	signal shift_register : std_logic_vector(7 downto 0) := (others => '0');
	signal data : std_logic_vector(7 downto 0);

begin
	process  (clk_i)
	begin
		if rising_edge(clk_i) then
			if rst_i = '0' then
				state <= wait_for_rx_start;
				data <= (others => '0');
				req_o <= '0';
			else
				case state is
					when wait_for_rx_start =>
						if rx = '0' then
							state <= wait_half_bit;
							baudrate_counter <= (max_counter / 2) - 1;
							req_o <= '1';
						end if;
						
					when wait_half_bit =>
						if baudrate_counter = 0 then
							state <= receive_bits;
							bit_counter <= 7;
							baudrate_counter <= max_counter - 1;
						else
							baudrate_counter <= baudrate_counter - 1;
						end if;
						
					when receive_bits =>
						if baudrate_counter = 0 then
							shift_register <= rx & shift_register(7 downto 1);
							if bit_counter = 0 then
								state <= wait_for_stop_bit;
							else
								bit_counter <= bit_counter - 1;
							end if;
							baudrate_counter <= max_counter - 1;
						else
							baudrate_counter <= baudrate_counter - 1;
						end if;
						
					when wait_for_stop_bit =>
						if baudrate_counter = 0 then
							state <= wait_for_rx_start;
							if rx = '1' then
								data <= shift_register;
								req_o <= '0';
							end if;
						else
							baudrate_counter <= baudrate_counter - 1;
						end if;
					end case;
				end if;
			end if;
		end process;
		
	data_o <= data;
		
end behave;