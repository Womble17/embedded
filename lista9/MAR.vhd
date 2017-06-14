library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
library std;
use std.textio.all;
Use work.txt_util.ALL;
use work.std_logic_textio.all;

entity MAR is
    Port (
           clk          : in    STD_LOGIC;
           ram_mar      : out   STD_LOGIC_VECTOR (4 downto 0);
           bus_data     : inout STD_LOGIC_VECTOR (15 downto 0)
			);
end MAR;


architecture Behavioral of MAR is

  type state_type is (IDLE, SLEEP);
  signal current_s : state_type := IDLE;
  signal next_s : state_type := IDLE;

  signal q    : std_logic_vector (15 downto 0) := (others => '0');
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
  begin
  case current_s is

    when IDLE =>
      --print("MAR: IDLE");
      if q(15 downto 13) = "001" then
        print("MAR: IDLE");
        ram_mar <= q(12 downto 8);
      end if;

    when SLEEP =>
      print("MAR SLEEP: " & str(sleep_counter));
      sleep_counter := sleep_counter - 1;

      if sleep_counter = 0 then
        next_s <= IDLE;
      end if;

  end case;
end process;


end Behavioral;
