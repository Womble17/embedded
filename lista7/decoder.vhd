library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

Use work.txt_util.ALL;

entity decoder is
    Port (
          clk  : in  STD_LOGIC;
          work  : in  STD_LOGIC;
          data_in   : in STD_LOGIC_VECTOR(7 downto 0);
          data_out   : out STD_LOGIC_VECTOR(3 downto 0)
			);
end decoder;

ARCHITECTURE Behavioral OF decoder IS
      signal check      : std_logic_vector(2 downto 0);
      signal temp       : std_logic_vector(6 downto 0);
      signal temp_out   : std_logic_vector(3 downto 0);
      signal parity     : std_logic;

BEGIN
-- cyclic register with taps
PROCESS(clk)
  variable check_value : integer;
  variable counter : integer := 0;

BEGIN
  counter := counter +1;

  --print("counter " & str(counter));
--if counter mod 3 = 2  and work = '1' then
  --print("dc " & str(counter));

  check(2) <= data_in(7) xor data_in(6) xor data_in(5) xor data_in(4);
  check(1) <= data_in(7) xor data_in(6) xor data_in(3) xor data_in(2);
  check(0) <= data_in(7) xor data_in(5) xor data_in(3) xor data_in(1);
  parity <= data_in(0) xor data_in(1) xor data_in(2) xor data_in(3) xor data_in(4) xor data_in(5) xor data_in(6) xor data_in(7);

  check_value := to_integer(unsigned(check));
  temp(6 downto 0) <= data_in(7 downto 1);

  if check_value /= 0 and parity = '1' then
    print("przeklamanie na pozycji " & str(check_value));
    print("in : " & str(data_in));
    temp(check_value-1) <= not temp(check_value-1);
    print("out: " & str(temp));
  elsif check_value/= 0 and parity = '0' then
    print("przeklamanie na dwoch pozycjach ");
    print("dane : " & str(data_in));
  end if;

  temp_out(3 downto 1) <= temp(6 downto 4);
  temp_out(0) <= temp(2);

  data_out <= temp_out;
  --print("dc out: " & str(temp_out));
--end if;
  --print("dec in : " & str(data_in));
  --print("dec out: " & str(data_out));
	--WAIT UNTIL clk'event AND clk='1';
END PROCESS;

END Behavioral;
