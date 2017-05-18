library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
Use work.txt_util.ALL;

entity encoder is
    Port (
          clk : in  STD_LOGIC;
          work  : in  STD_LOGIC;
          data_in   : in STD_LOGIC_VECTOR(3 downto 0);
          data_out   : out STD_LOGIC_VECTOR(7 downto 0)
			);
end encoder;

ARCHITECTURE Behavioral OF encoder IS



BEGIN

-- cyclic register with taps
PROCESS(data_in)
variable temp_out  : std_logic_vector(7 downto 0);
variable counter : integer := 0;

BEGIN
counter := counter +1;

--if counter mod 3 = 0 and work = '1'  then
  --print("en " & str(counter));

	temp_out(7 downto 5) := data_in(3 downto 1);
	temp_out(3) := data_in(0);
  temp_out(1) := data_in(0) xor data_in(1) xor data_in(3);
  temp_out(2) := data_in(0) xor data_in(2) xor data_in(3);
  temp_out(4) := data_in(1) xor data_in(2) xor data_in(3);
  temp_out(0) := temp_out(1) xor temp_out(2) xor temp_out(3) xor temp_out(4) xor temp_out(5) xor temp_out(6) xor temp_out(7);

  data_out <= temp_out;
  --print("en out: " & str(temp_out));
--end if;
  --print("enc in : " & str(data_in));
  --print("enc out: " & str(data_out));
	--WAIT UNTIL clk'event AND clk='1';
END PROCESS;

END Behavioral;
