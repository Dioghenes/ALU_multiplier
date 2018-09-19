library ieee;
use ieee.std_logic_1164.all;

-- NOTE : this component receives the select signal from the booth_encoder and 
--        puts on the output 0, k*A or 2*k*A where k depends on the level.

entity MUX31_GENERIC is
	generic(N_BIT : integer := 8);
	port(two	: in std_logic_vector(N_BIT-1 downto 0);
		 one 	: in std_logic_vector(N_BIT-1 downto 0);
		 zero	: in std_logic_vector(N_BIT-1 downto 0);
		 sel 	: in std_logic_vector(1 downto 0);
		 Y   	: out std_logic_vector(N_BIT-1 downto 0));
end entity;

architecture behavioral of MUX31_GENERIC is
begin
	behavior : process (two,one,zero,sel)
	begin
		case sel is
			when "10" =>
				Y <= two;
			when "01" =>
				Y <= one;
			when "00" =>
				Y <= zero;
			when others =>
				Y <= zero;
		end case;
	end process;
end architecture;
