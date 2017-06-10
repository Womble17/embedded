library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
USE work.txt_util.ALL;

entity clock is
  GENERIC (NBit : positive);
    Port ( clk     : in    STD_LOGIC;
           div     : in    STD_LOGIC_VECTOR(7 downto 0);
           clk_out : inout STD_LOGIC_VECTOR (NBit-1 downto 0) := (others => '0')
			);
end clock;

ARCHITECTURE Behavioral OF clock IS
BEGIN
  PROCESS(clk)
    VARIABLE counter : integer := 0;
  BEGIN
  if rising_edge(clk) then
    counter := counter +1;
    for i in NBit-1 downto 1 loop
      IF (counter mod (to_integer(unsigned(div)) * (2**(i-1)))) = 0 THEN
        for j in 0 to i loop
          clk_out(j) <= not clk_out(j);
        end loop;
        exit;
      END IF;
    end loop;
end if;
    clk_out(0) <= clk;

    IF counter = (to_integer(unsigned(div)) * ((2**(NBit-1)))) THEN
      counter := 0;
      for j in 1 to NBit-1 loop
        clk_out(j) <= '0';
      end loop;
    END IF;
  END PROCESS;
END Behavioral;
