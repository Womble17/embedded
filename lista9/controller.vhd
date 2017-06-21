library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
Use work.txt_util.ALL;
--USE IEEE.std_logic_unsigned.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.pack.all;

entity controller is
    generic ( identifier : std_logic_vector (7 downto 0) := "10101010" );
    Port (
        clk          : in  STD_LOGIC;
			  bus_data     : inout std_logic_vector (15 downto 0)
			  );
end controller;

architecture Behavioral of controller is

  -- statemachine definitions
  type state_type is (IDLE, FETCH, DECODE, EXECUTE, STORE, SLEEP);
  signal current_s : state_type := IDLE;
  signal next_s : state_type := IDLE;

  -- command definitions
  type cmd_type is (load, store, add, subt, inp, outp, halt, skip, jump);
  attribute enum_encoding: string;
  attribute enum_encoding of cmd_type: type is
  				         "0001  0010   0011 0100  0101 0110  0111  1000  1001";
  signal current_cmd : cmd_type := halt;



begin

stateadvance: process(clk)
begin
  if rising_edge(clk)
  then
    q  <= conn_bus;
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
      print("MAR: SET NEW ADDRESS " & str(q(4 downto 0)));
      ram_mar <= q(4 downto 0);
      sleep_counter := 2;
      next_s <= SLEEP;
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
