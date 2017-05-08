library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;

entity ram is
	port(
			clk, RST,req_rx: in std_logic;
			data : in std_logic_vector(7 downto 0);
			ADDRESS : out std_logic_vector (3 downto 0);
			SCLK , LATCH, BLANK : out std_logic;
			R0, G0, B0, R1, G1, B1 : out std_logic);
			--tx_out : out std_logic);
end ram;
	architecture behave of ram is
		type state_type is(
		start_byte,address_byte,
		receive_pixelR,receive_pixelG,receive_pixelB,
		plus_index);
		signal state : state_type := start_byte;
		subtype row is std_logic_vector(63 downto 0);
		type color is array(0 to 31) of row;
		signal R,G,B,Rtmp,Gtmp,Btmp : color;
		--subtype byte is std_logic_vector(2047 downto 0);
		--signal R,G,B : std_logic_vector(2047 downto 0);
		signal TR,TG,TB : std_logic_vector(63 downto 0);

		--type mem is array(0 to 2) of byte;
		--signal ram3x2048: mem;
		signal index : integer range 0 to 63 := 63;
		signal indexs : integer range 0 to 15 := 0;
		signal addr : integer;
		signal addr_temp : std_logic_vector(13 downto 0);
		signal next_index : std_logic;
--		signal temp_tx : std_logic := '1';

	begin
--	tx : entity work.rs232_tx 
--	  generic map(
--		 SYSTEM_SPEED =>  50e6,  	-- clock speed, in Hz
--		 BAUDRATE     =>  9600)  	-- baudrate
--	  port map(
--		 clk_i  => CLK,   -- system clock
--		 rst_i  => '1', 	-- synchronous reset, active-Low
--		 req_i  => temp_tx, 	-- Tx request 
--		 tx     => tx_out ); 	-- Tx output 


	LED : entity work.ledpanel 
	generic map( data_len => 2048,
				column => 64,
				addr_port => 4)
	port map(
		CLK => CLK,
		START => '1',
		DATA_R => R(0+indexs)&R(16+indexs),
		DATA_G => G(0+indexs)&G(16+indexs), 
		DATA_B => B(0+indexs)&B(16+indexs),
		ADDRESS => ADDRESS,
		SCLK => SCLK, 
		LATCH => LATCH, 
		BLANK => BLANK,
		R0 => R0,
		G0 => G0,
		B0 => B0,
		R1 => R1,
		G1 => G1,
		B1 => B1,
		nexts => next_index);
		
		process(next_index)
			begin
				if next_index = '1' then
					indexs<=indexs+1;
				end if;
		end process;
		
		process(clk)
			begin
				if rising_edge(clk) then
					case state is
						when start_byte =>
--							temp_tx <= '1';
							if (req_rx = '1') then
								if data = x"23" then
									state <= address_byte;
								end if;
							end if;
						when address_byte =>
--							temp_tx <= '1';
							if (req_rx ='1') then
								addr <=  to_integer(unsigned(data));
								state <= receive_pixelR;
							end if;
						when receive_pixelR =>
							if (req_rx ='1') then
								TR(index) <= data(5);
								TR(index-1) <= data(2);
								state <= receive_pixelG;
							end if;
						when receive_pixelG =>
							if (req_rx ='1') then
								TG(index) <= data(5);
								TG(index-1) <= data(2);
								state <= receive_pixelB;
							end if;
						when receive_pixelB =>
							if (req_rx ='1') then
								TB(index) <= data(5);
								TB(index-1) <= data(2);
								state <= plus_index;
							end if;
						when plus_index =>
							if index > 2 then
								index <= index - 2;
								state <= receive_pixelR;
							else
								--send
								R(addr) <= TR;
								G(addr) <= TG;
								B(addr) <= TB;
								index <= 63;
								state <= start_byte;
--								if addr = 30 then
--									R<= Rtmp;
--									G<= Gtmp;
--									B<= Btmp;
--								end if;
							end if;
					end case;
				end if;
		end process;
		
	
end behave;