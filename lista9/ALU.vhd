library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
library std;
use std.textio.all;
Use work.txt_util.ALL;
use work.std_logic_textio.all;

entity AC is
    Port (
           clk          : in    STD_LOGIC;
           alu_in       : in STD_LOGIC_VECTOR (15 downto 0);
           alu_out      : out STD_LOGIC_VECTOR (15 downto 0);
           bus_data     : inout STD_LOGIC_VECTOR (15 downto 0)
			);
end AC;


architecture Behavioral of AC is

  type state_type is (IDLE, SLEEP, SET_DATA, GET_DATA);
  signal current_s : state_type := IDLE;
  signal next_s : state_type := IDLE;

  type cmd_type is (nop, load, store, add, subt);
  signal current_cmd : cmd_type := NOP;

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
    variable adr : std_logic_vector(2 downto 0) := "000";
    variable cmd : std_logic_vector(2 downto 0) := "000";
    variable sleep_counter : integer := 0;

  begin
  case current_s is

    when IDLE =>
      --print("RAM: IDLE");

      adr := q(15 downto 13);
      if adr = "000" then

        cmd := q(12 downto 10);
        case cmd is
          when "001" =>
            current_cmd <= load;
            next_s <= GET_DATA;
          when "010" =>
            current_cmd <= store;
            next_s <= SET_DATA;
          when "011" =>
            current_cmd <= add;
            next_s <= IDLE;
          when "100" =>
            current_cmd <= subt;
            next_s <= IDLE;

          when others => current_cmd <= nop;
        end case;
      else
        next_s <= IDLE;
      end if;

    when SET_DATA =>
      print("RAM: SET DATA");
      next_s <= IDLE;

    when GET_DATA =>
      print("RAM: GET DATA");
      next_s <= IDLE;

    when SLEEP =>
      sleep_counter := sleep_counter - 1;
      if sleep_counter = 0 then
        next_s <= IDLE;
      end if;

  end case;
  end process;


end Behavioral;
