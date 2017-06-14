library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
library std;
use std.textio.all;
Use work.txt_util.ALL;
use work.std_logic_textio.all;

entity RAM is
    Port (
           clk          : in    STD_LOGIC;
           debug        : in    STD_LOGIC;
           ram_mar      : in    STD_LOGIC_VECTOR (4 downto 0);
           bus_data     : inout STD_LOGIC_VECTOR (15 downto 0)
			);
end RAM;


architecture Behavioral of RAM is
  constant ADDRESS_WIDTH : integer := 5;
  constant DATA_WIDTH    : integer := 16;

  type ram_t is array (0 to 2 ** (ADDRESS_WIDTH + 1) - 1) of std_logic_vector(DATA_WIDTH-1 downto 0);

  signal memory : ram_t := (others => X"0000");
  signal bin_value : std_logic_vector(15 downto 0):=X"0000";


  type state_type is (IDLE, SET_DATA, GET_DATA);
  signal current_s : state_type := IDLE;
  signal next_s : state_type := IDLE;

  type cmd_type is (nop, load, store);
  signal current_cmd : cmd_type := NOP;

  signal q : std_logic_vector (15 downto 0) := (others => '1');

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
            current_cmd <= load;
            next_s <= GET_DATA;
          when "100" =>
            current_cmd <= load;
            next_s <= GET_DATA;

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

  end case;
end process;

  read_input_file : process
    variable v_ILINE     : line;
    variable v_ADD_TERM1 : std_logic_vector(15 downto 0);
    file in_file : text;
    variable ptr : integer := 0;
  begin
    file_open(in_file, "code.txt",  read_mode);

    while not endfile(in_file) loop
      readline(in_file, v_ILINE);
      read(v_ILINE, v_ADD_TERM1);

      -- Pass the variable to a signal to allow the ripple-carry to use it
      memory(ptr) <= v_ADD_TERM1;
      ptr := ptr + 1;
      wait for 5 ns;

    end loop;

    file_close(in_file);
    wait;
  end process;

  print_memory : process(debug)
  variable ctr : integer := 0;
  begin
    if ctr > 0 then
      for j in 0 to 31 loop
        print(str(to_integer(unsigned(memory(j)))));
      end loop;
    end if;
    ctr := ctr + 1;
  end process;

end Behavioral;
