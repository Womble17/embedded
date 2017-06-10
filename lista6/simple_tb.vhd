LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use std.textio.all;
USE work.txt_util.ALL;

ENTITY simple_tb IS
END simple_tb;

ARCHITECTURE behavior OF simple_tb IS

    constant parameter : positive := 6;
    -- UUT (Unit Under Test)
    COMPONENT clock
    GENERIC (NBit : positive);
    PORT ( clk     : in    STD_LOGIC;
           div     : in    STD_LOGIC_VECTOR(7 downto 0);
           clk_out : inout STD_LOGIC_VECTOR (parameter-1 downto 0)
      );
    END COMPONENT;

   -- input signals
   signal clk     : std_logic := '0';
   signal clk_out : STD_LOGIC_VECTOR (parameter-1 downto 0) := (others => '0');
   signal div     : STD_LOGIC_VECTOR (7 downto 0) := (3 => '1', 1=>'1', others => '0');

   constant clk_period : time := 4 ns;



BEGIN
	-- instantiate UUT
   uut: clock
   GENERIC MAP (NBit => parameter)
   PORT MAP (
          clk => clk,
          div => div,
          clk_out => clk_out
    );

   clk_process :PROCESS
   BEGIN
		clk <= '1';
		WAIT FOR clk_period/2;
		clk <= '0';
		WAIT FOR clk_period/2;
   END PROCESS;

END;
