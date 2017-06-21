library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
library std;
use std.textio.all;
Use work.txt_util.ALL;
use work.std_logic_textio.all;

entity OUTREG is
    Port (
           clk          : in    STD_LOGIC;
           bus_data     : inout STD_LOGIC_VECTOR (15 downto 0)
			);
end OUTREG;


architecture Behavioral of OUTREG is

  type state_type is (IDLE, SLEEP, PRINT_DATA);
  signal current_s : state_type := IDLE;
  signal next_s : state_type := IDLE;

  signal q    : std_logic_vector (15 downto 0) := (others => '0');
  signal prnt : std_logic := '0';

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
      --print("OUTREG: IDLE");
      if q(15 downto 13) = "001" then
        sleep_counter := 1;
        next_s <= SLEEP;
      elsif q(15 downto 13) = "110" then
        sleep_counter := 1;
        next_s <= SLEEP;
        prnt <= '1';

      end if;

    when SLEEP =>
      print("OUTREG SLEEP: " & str(sleep_counter));
      sleep_counter := sleep_counter - 1;

      if sleep_counter = 0 then
        if prnt = '0' then
          next_s <= IDLE;
        else
          next_s <= PRINT_DATA;
        end if;
      end if;


    when PRINT_DATA =>
      print("OUTREG PRINT: " & str(bus_data));
      prnt <= '0';
      next_s <= IDLE;


  end case;
end process;


end Behavioral;
