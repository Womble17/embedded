library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
library std;
use std.textio.all;
Use work.txt_util.ALL;
use work.std_logic_textio.all;

entity INREG is
    Port (
           clk          : in    STD_LOGIC;
           bus_data     : inout STD_LOGIC_VECTOR (15 downto 0);
           clk_run      : inout STD_LOGIC

			);
end INREG;


architecture Behavioral of INREG is

  type state_type is (IDLE, SLEEP, SEND_TO_BUS, READ_STDIN);
  signal current_s : state_type := IDLE;
  signal next_s : state_type := IDLE;

  signal q    : std_logic_vector (15 downto 0) := (others => '0');
  signal data : std_logic_vector (15 downto 0) := (others => '0');
  signal sending     : std_logic := '0';

  signal stop_clock : std_logic := '0';

begin


  stateadvance: process(clk)
  begin
    if rising_edge(clk)
    then
      q  <= bus_data;
      current_s <= next_s;
    end if;
  end process;


  nextstate: process(current_s,q)
    variable sleep_counter : integer := 0;
    variable st : string(15 to 0);

  begin
  case current_s is

    when IDLE =>
      --print("INTREG: IDLE");
      if q(15 downto 13) = "111" then
        sleep_counter := 1;
        next_s <= SLEEP;
      elsif q(15 downto 13) = "101" then
        next_s <= READ_STDIN;

      end if;
      sending <= '0';
      stop_clock <= '0';

    when SLEEP =>
      print("INREG SLEEP: " & str(sleep_counter));
      sleep_counter := sleep_counter - 1;

      if sleep_counter = 0 then
        next_s <= IDLE;
      end if;


    when SEND_TO_BUS =>
      print("INREG SEND_TO_BUS: ");
      sending <= '1';
      next_s <= IDLE;

    when READ_STDIN =>
      print("INREG READ_STDIN: ");
      clk_run <= '0';
      str_read(input, st);
      print("READ LINE: " & st);
      next_s <= IDLE;


  end case;
end process;

bus_data <= data when sending = '1' else "ZZZZZZZZZZZZZZZZ";
--clk_run <= '0' when stop_clock = '1' else 'Z';

end Behavioral;
