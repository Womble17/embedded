library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
library std;
use std.textio.all;
Use work.txt_util.ALL;
use work.std_logic_textio.all;

entity AC is
    Port (
           clk          : in STD_LOGIC;
           ac_in        : in STD_LOGIC_VECTOR (15 downto 0);
           ac_out       : out STD_LOGIC_VECTOR (15 downto 0);
           bus_data     : inout STD_LOGIC_VECTOR (15 downto 0)
			);
end AC;


architecture Behavioral of AC is

  type state_type is (IDLE, SLEEP, GET_ALU, GET_BUS, SEND_TO_BUS);
  signal current_s : state_type := IDLE;
  signal next_s : state_type := IDLE;

  type cmd_type is (nop, load, store, add, subt);
  signal current_cmd : cmd_type := NOP;

  signal q    : std_logic_vector (15 downto 0) := (others => '0');
  signal data : std_logic_vector (15 downto 0) := (others => '0');
  signal sending     : std_logic := '0';

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
      if adr = "111" then

        cmd := q(12 downto 10);
        case cmd is
          when "001" =>
            current_cmd <= load;
            sleep_counter := 1;
            next_s <= SLEEP;
          when "010" =>
            current_cmd <= store;
            next_s <= IDLE;
          when "011" =>
            current_cmd <= add;
            sleep_counter := 2;
            next_s <= SLEEP;
          when "100" =>
            current_cmd <= subt;
            sleep_counter := 2;
            next_s <= SLEEP;

          when others => current_cmd <= nop;
        end case;
      elsif adr = "110" then
        next_s <= SEND_TO_BUS;
      else
        next_s <= IDLE;
      end if;
      sending <= '0';

    when GET_BUS =>
      print("AC: GET_BUS");
      data <= bus_data;
      next_s <= IDLE;

    when SEND_TO_BUS =>
      print("AC: SEND TO BUS");
      print("AC: " & str(data));
      sending <= '1';
      next_s <= IDLE;

    when GET_ALU =>
      print("AC: GET ALU");
      data <= ac_in;
      next_s <= IDLE;

    when SLEEP =>
      sleep_counter := sleep_counter - 1;
      if sleep_counter = 0 then
        case current_cmd is
          when load =>
            next_s <= GET_BUS;
          when add =>
            next_s <= GET_ALU;
          when subt =>
            next_s <= GET_ALU;
          when others => next_s <= IDLE;
        end case;
      end if;

  end case;
  end process;

bus_data <= data when sending = '1' else "ZZZZZZZZZZZZZZZZ";
ac_out <= data;

end Behavioral;
