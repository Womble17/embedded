LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY simple_tb IS
END simple_tb;

ARCHITECTURE behavior OF simple_tb IS

    -- UUT (Unit Under Test)
    COMPONENT lfsr
    PORT(
         clk : IN  std_logic;
         q   : inout  STD_LOGIC_VECTOR (15 downto 0) := (OTHERS => '0')
        );
    END COMPONENT;

   -- input signals
   signal clk : std_logic := '0';

   -- input/output signal
   signal q : STD_LOGIC_VECTOR (15 downto 0);

   -- set clock period
   constant clk_period : time := 5 ns;

BEGIN
	-- instantiate UUT
   uut: lfsr PORT MAP (
          clk => clk,
          q   => q
        );

   -- clock management process
   -- no sensitivity list, but uses 'wait'
   clk_process :PROCESS
   BEGIN
		clk <= '0';
		WAIT FOR clk_period/2;
		clk <= '1';
		WAIT FOR clk_period/2;
   END PROCESS;

END;
