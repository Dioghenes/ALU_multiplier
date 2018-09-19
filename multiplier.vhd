library ieee;
use ieee.std_logic_1164.all;

entity BOOTHMUL is
	generic(N_BIT : integer := 32);
	port(A	: in std_logic_vector(N_BIT/2-1 downto 0);
		 B  : in std_logic_vector(N_BIT/2-1 downto 0);
		 P  : out std_logic_vector(N_BIT-1 downto 0));
end entity;

architecture structural of BOOTHMUL is
	-- Used components
	component P4ADD is
		generic(log2_N_BIT: integer := 5);
		port(	A	    : in std_logic_vector(2**log2_N_BIT-1 downto 0);
			 	B 	    : in std_logic_vector(2**log2_N_BIT-1 downto 0);
				AddSub  : in std_logic;
				SUM     : out std_logic_vector(2**log2_N_BIT-1 downto 0);
			 	Cout	: out std_logic);
	end component;
	
	component booth_encoder is
		port(nibble		: in std_logic_vector(2 downto 0);
			 mux_sel	: out std_logic_vector(1 downto 0);
			 add_sub	: out std_logic);
	end component;
	
	component MUX31_GENERIC is
		generic(N_BIT : integer := 8);
		port(two	: in std_logic_vector(N_BIT-1 downto 0);
			 one 	: in std_logic_vector(N_BIT-1 downto 0);
			 zero	: in std_logic_vector(N_BIT-1 downto 0);
			 sel 	: in std_logic_vector(1 downto 0);
			 Y   	: out std_logic_vector(N_BIT-1 downto 0));
	end component;
	
	-- Definition of new types
	type signal_vector  is array(N_BIT/2-1 downto 0) of std_logic_vector(N_BIT-1 downto 0);
	type signal_vector2 is array(N_BIT/4 downto 0) of std_logic_vector(N_BIT-1 downto 0);
	type select_vector  is array(N_BIT/4-1 downto 0) of std_logic_vector(1 downto 0);
	
	-- Internal signals used
	signal multiples_vector : signal_vector;		-- This vector contains A, 2*A, 4*A ...
	signal out_mux       	: signal_vector2;		-- This vector contains the outputs of the mux to be connected to the RCA
	signal out_adder		: signal_vector2;		-- Vector containing the partial outputs of RCAs
	signal add_sub_vector  	: std_logic_vector(N_BIT/4-1 downto 0);	-- AddSub Outputs of the encoders
	signal sel_mux_vector  	: select_vector;												-- Select Outputs of the encoders
	signal cout_dead		: std_logic_vector(N_BIT/2-1 downto 0); -- Used to write 
	signal ZERO_SIG			: std_logic_vector(N_BIT-1 downto 0);   -- Useful when 0 has to be added
	signal B_expanded		: std_logic_vector(N_BIT/2 downto 0);   -- The Booth algo operates on 2*log2_N_BIT+1 so this signal manage 
																																	--    the additional bit.
begin
	
	ZERO_SIG <= (others => '0');
	out_adder(0) <= (others => '0');
	B_expanded <= B & '0';
 	
	-- *****************************************************
	-- Generation of multiples
	-- *****************************************************
	multiples_gen : for row in 0 to N_BIT/2-1 generate
		-- First row, no shift
		row_0 : if row=0 generate
			multiples_vector(row)(N_BIT-1 downto N_BIT/2) <= (others => A(N_BIT/2-1));
			multiples_vector(row)(N_BIT/2-1 downto 0) <= A;
		end generate row_0;
		
		-- Other rows, 1 shift each time
		row_i : if row<=N_BIT/2-1 and row>0 generate
			multiples_vector(row)(N_BIT-1 downto row+N_BIT/2) <= (others => A(N_BIT/2-1));
			multiples_vector(row)(row-1 downto 0) <= (others => '0');
			multiples_vector(row)(row+N_BIT/2-1 downto row) <= A;
		end generate row_i;
	end generate multiples_gen;
	
	-- *****************************************************
	-- Generation of structure: one encoder, one mux31 and one rca per each iteration
	-- *****************************************************
	struct_gen : for row in 0 to N_BIT/4-1 generate
		enc_i : booth_encoder port map(B_expanded(2*(row+1) downto 2*row),sel_mux_vector(row),add_sub_vector(row));
		mux_i : MUX31_GENERIC generic map(N_BIT)
							  port map(multiples_vector(2*row+1),multiples_vector(2*row),ZERO_SIG,sel_mux_vector(row),out_mux(row));
		rca_i : P4ADD generic map(5)
				      port map(out_adder(row),out_mux(row),add_sub_vector(row),out_adder(row+1),cout_dead(row));
	end generate struct_gen;
	
	-- *****************************************************
	-- Connection of the product signal to output port
	-- *****************************************************
	P <= out_adder(N_BIT/4);
	
end architecture;
