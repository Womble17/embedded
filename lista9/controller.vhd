library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
Use work.txt_util.ALL;
--USE IEEE.std_logic_unsigned.ALL;
use IEEE.NUMERIC_STD.ALL;

entity controller is
    Port (
        clk          : in  STD_LOGIC;
			  bus_data     : inout std_logic_vector (15 downto 0)
			  );
end controller;

architecture Behavioral of controller is

  -- statemachine definitions
  type state_type is (IDLE, FETCH, FETCH_SEND_REQ, FETCH_WAIT, FETCH_READ, DECODE, EXECUTE, STORE, SLEEP, SKIP_READ, SKIP_EXEC);
  signal current_s : state_type := IDLE;
  signal next_s : state_type := IDLE;

  -- command definitions
  type cmd_type is (load, store, add, subt, inp, outp, halt, skip, jump);
  attribute enum_encoding: string;
  attribute enum_encoding of cmd_type: type is
  				         "0001  0010   0011 0100  0101 0110  0111  1000  1001";
  signal current_cmd : cmd_type := halt;

  signal sending     : std_logic := '0';
  signal data : std_logic_vector (15 downto 0) := (others => '0');
  signal q : std_logic_vector (15 downto 0) := (others => '0');


begin

  stateadvance: process(clk)
  begin
    if rising_edge(clk)
    then
      q  <= bus_data;
      current_s <= next_s;
    end if;
  end process;


nextstate: process (current_s, q)
  variable PC : std_logic_vector (4 downto 0) := (others => '0');
  variable IR : std_logic_vector (3 downto 0) := (others => '0');
  variable adr: std_logic_vector (4 downto 0) := (others => '0');
  variable sleep_counter : integer := 0;

begin
  case current_s is

  when IDLE =>
    if q(15 downto 0) = "0111111111111111" then
      print("---===START===---");
      next_s <= FETCH;
    end if;
    sending <= '0';

    --next_s <= IDLE;

  when FETCH =>
    print("FETCH");
    data(15 downto 10) <= "111111";
    data(4 downto 0) <= PC;
    PC := std_logic_vector(to_unsigned(to_integer(unsigned(PC) + 1), PC'length));
    next_s <= FETCH_SEND_REQ;


  when FETCH_SEND_REQ =>
    sending <= '1';
    next_s <= FETCH_WAIT;

  when FETCH_WAIT =>
    next_s <= FETCH_READ;
    if sending = '1' then
      sending <= '0';
      next_s <= FETCH_WAIT;
    end if;

  when FETCH_READ =>

    print("FETCH_READ");
    IR := bus_data(15 downto 12);
    adr := bus_data(11 downto 7);
    print("BUS " & str(bus_data));

    next_s <= DECODE;

  when DECODE =>

    print("DECODE IR: " & str(IR));
    case IR is
			when "0001" => current_cmd <= load;
      when "0010" => current_cmd <= store;
      when "0011" => current_cmd <= add;
			when "0100" => current_cmd <= subt;
      when "0101" => current_cmd <= inp;
			when "0110" => current_cmd <= outp;
      when "0111" => current_cmd <= halt;
      when "1000" => current_cmd <= skip;
      when "1001" => current_cmd <= jump;
      when others => current_cmd <= halt;
		end case;
    next_s <= EXECUTE;

  when EXECUTE =>
  case current_cmd is

    when load =>
    print(" RUN load " & str(to_integer(unsigned(adr))));
    data(15 downto 10) <= "111001";
    data(4 downto 0) <= adr;
    sending <= '1';
    sleep_counter := 2;
    next_s <= SLEEP;

    when store	=>
    print(" RUN store " & str(to_integer(unsigned(adr))));
    next_s <= IDLE;

    when add =>
    print(" RUN add " & str(to_integer(unsigned(adr))));
    data(15 downto 10) <= "111011";
    data(4 downto 0) <= adr;
    sending <= '1';
    sleep_counter := 2;
    next_s <= SLEEP;

    when subt =>
    print(" RUN subt " & str(to_integer(unsigned(adr))));
    data(15 downto 10) <= "111100";
    data(4 downto 0) <= adr;
    sending <= '1';
    sleep_counter := 2;
    next_s <= SLEEP;

    when inp =>
    print(" RUN inp");
    next_s <= IDLE;

    when outp =>
    print(" RUN outp");
    data(15 downto 13) <= "110";
    data(0) <= '0';
    sending <= '1';

    next_s <= IDLE;

    when halt =>
    print(" RUN halt");
    next_s <= IDLE;

    when skip =>
    print(" RUN skip");
    data(15 downto 13) <= "110";
    data(0) <= '1';
    sending <= '1';
    next_s <= SKIP_READ;

    when jump =>
    print(" RUN jump");
    PC := adr;
    next_s <= FETCH;

    when others =>
      print(" RUN OTHER");
      next_s <= IDLE;
   end case;

  when SLEEP =>
    sending <= '0';
    print("controller SLEEP: " & str(sleep_counter));
    sleep_counter := sleep_counter - 1;
    if sleep_counter = 0 then
     next_s <= FETCH;
    end if;

  when SKIP_READ =>
  sending <= '0';
  case adr(4 downto 3) is
    when "00" =>
      if to_integer(signed(bus_data)) < 0 then
        PC := std_logic_vector(to_unsigned(to_integer(unsigned(PC) + 1), PC'length));
        print("PC + 1");
      end if;
    when "01" =>
      if to_integer(signed(bus_data)) = 0 then
        PC := std_logic_vector(to_unsigned(to_integer(unsigned(PC) + 1), PC'length));
        print("PC + 1");
      end if;
    when "10" =>
      if to_integer(signed(bus_data)) > 0 then
        PC := std_logic_vector(to_unsigned(to_integer(unsigned(PC) + 1), PC'length));
        print("PC + 1");
      end if;

    when others => current_cmd <= halt;
  end case;

  when others => next_s <= IDLE;


end case;
end process;

bus_data <= data when sending = '1' else "ZZZZZZZZZZZZZZZZ";

end Behavioral;
