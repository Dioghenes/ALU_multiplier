library ieee;
use ieee.std_logic_1164.all;

-- NOTE : the Booth encoder receives 3 bits (nibble) as inputs from addend B and generates
--				an AddSub signal and a MuxSel signal (choose what multiple to add or subtract)

entity booth_encoder is
	port(nibble		: in std_logic_vector(2 downto 0);
		   mux_sel	: out std_logic_vector(1 downto 0);
		   add_sub	: out std_logic);
end booth_encoder;

architecture behavioral of booth_encoder is
begin
	behavior : process (nibble)
	begin
		case nibble is
			when "000" => 
				mux_sel <= "00";
				add_sub <= '0';
			when "001" => 
				mux_sel <= "01";
				add_sub <= '0';
			when "010" => 
				mux_sel <= "01";
				add_sub <= '0';
			when "011" => 
				mux_sel <= "10";
				add_sub <= '0';
			when "100" => 
				mux_sel <= "10";
				add_sub <= '1';
			when "101" => 
				mux_sel <= "01";
				add_sub <= '1';
			when "110" => 
				mux_sel <= "01";
				add_sub <= '1';
			when "111" => 
				mux_sel <= "00";
				add_sub <= '1';
			when others =>
				mux_sel <= "00";
				add_sub <= '0';
		end case;
	end process;
end behavioral;
