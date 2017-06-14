library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
Use work.txt_util.ALL;
--USE IEEE.std_logic_unsigned.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.pack.all;
-----------------------------------------------------------------------
-- a (working) skeleton template for slave device on 8-bit bus
--    capable of executing commands sent on the bus in the sequence:
--    1) device_address (8 bits)
--		2) cmd_opcode (4 bits) & reserved (4 bits)
--		3) (optional) cmd_args (8 bits)
--
-- currently supported commands:
-- 	* ID 			[0010] - get device address
-- 	* DATA_REQ 	[1111] - send current result in the next clockpulse
-- 	* NOP 		[0000] - don't do anything
-----------------------------------------------------------------------
-- debugging information on current state of statemachine and command
-- executed and input buffer register is given in outputs, vstate,
-- vcurrent_cmd and vq, respectively
-----------------------------------------------------------------------

entity slave is
    generic ( identifier : std_logic_vector (7 downto 0) := "10101010" );
    Port (
        conn_bus     : inout  STD_LOGIC_VECTOR (7 downto 0);
        clk          : in  STD_LOGIC;
			  state        : out STD_LOGIC_VECTOR (5 downto 0);
			  vq           : out std_logic_vector (7 downto 0);
			  vcurrent_cmd : out std_logic_vector(3 downto 0)
			  );
end slave;

architecture Behavioral of slave is

-- statemachine definitions
type state_type is (IDLE, CMD, RUN, READ_DATA_1, READ_DATA_2, MUTE_PROCESSORS, WAIT_FOR_DATA, SEND_DATA, EXECUTE, SLEEP, SHORT_SLEEP, SET_ADD, SET_CMD, SET_SLP, SET_OPR);
signal current_s : state_type := IDLE;
signal next_s : state_type := IDLE;
-- for debugging entity's state
signal vstate : std_logic_vector(5 downto 0) := (others => '0');

-- command definitions
type cmd_type is (NOP, ADD, SUB, ID, CRC, DATA_REQ, COM, INC);
attribute enum_encoding: string;
attribute enum_encoding of cmd_type: type is
				  "0000 0001 0011 0010 0111 1111 0101 1001";
signal current_cmd : cmd_type := NOP;

-- input buffer
signal q : std_logic_vector (7 downto 0) := (others => '0');

-- for storing results and indicating it is to be sent to bus
signal result_reg  : std_logic_vector (7 downto 0) := (others => '0');
signal sending     : std_logic := '0';
signal long_mute        : std_logic := '0';
signal short_mute        : std_logic := '0';


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
  variable fourbit : std_logic_vector(3 downto 0) := "0000";
  variable acc1 : std_logic_vector (7 downto 0) := (others => '0');
  variable acc2 : std_logic_vector (7 downto 0) := (others => '0');
  variable sleep_counter : integer := 1;
begin

 case current_s is

   when IDLE =>
    --print(str(to_integer(unsigned(identifier))) & " IDLE");
		vstate <= "000001";		-- set for debugging
    if q = "11111111" then
        next_s <= SLEEP;
    elsif q = "11111110" then
        next_s <= SHORT_SLEEP;
		elsif q = identifier and sending /= '1' then
	      next_s <= CMD;
		else
			next_s <= IDLE;
		end if;
		sending <= '0';

	when CMD =>
    print(str(to_integer(unsigned(identifier))) & " COMMAND");
		vstate <= "000010";
		-- command decode
		fourbit := q(7 downto 4);
		case fourbit is
			when "0000" => current_cmd <= NOP;
      when "0010" => current_cmd <= ID;
      when "0100" => current_cmd <= DATA_REQ;
			when "0001" => current_cmd <= ADD;
      when "0011" => current_cmd <= SUB;
			when "0111" => current_cmd <= CRC;

      when "0101" => current_cmd <= COM;
      when "1001" => current_cmd <= INC;
			when others => current_cmd <= NOP;
		end case;
		next_s <= RUN;


	when RUN =>
		vstate <= "000100";
		-- determine action based on current_cmd state
		case current_cmd is

			when NOP =>
      print(str(to_integer(unsigned(identifier))) & " RUN NOP");
      result_reg <= result_reg;
      next_s <= IDLE;

			when ID	=>
      print(str(to_integer(unsigned(identifier))) & " RUN ID");
      result_reg <= identifier;
      next_s <= IDLE;

			when DATA_REQ =>
      print(str(to_integer(unsigned(identifier))) & " RUN REQ");
      short_mute <= '1';
      next_s <= SEND_DATA;

      when ADD =>
      print(str(to_integer(unsigned(identifier))) & " RUN ADD");
      next_s <= WAIT_FOR_DATA;

      when SUB =>
      print(str(to_integer(unsigned(identifier))) & " RUN SUB");
      next_s <= WAIT_FOR_DATA;

      when CRC =>
      print(str(to_integer(unsigned(identifier))) & " RUN CRC");
      next_s <= WAIT_FOR_DATA;

      when COM =>
      print(str(to_integer(unsigned(identifier))) & " RUN COM");
      next_s <= WAIT_FOR_DATA;

      when INC =>
      print(str(to_integer(unsigned(identifier))) & " RUN INC");
      next_s <= WAIT_FOR_DATA;

			when others =>
        print(str(to_integer(unsigned(identifier))) & " RUN OTHER");
        result_reg <= result_reg;
        next_s <= IDLE;
		 end case;


    when READ_DATA_1 =>
        acc1 := q;
        if current_cmd = INC then
          next_s <= EXECUTE;
        else
          next_s <= READ_DATA_2;
        end if;
        print(str(to_integer(unsigned(identifier))) & " READ DATA 1: " & str(acc1));

    when READ_DATA_2 =>
        acc2 := q;
        print(str(to_integer(unsigned(identifier))) & " READ DATA 2: " & str(acc2));
        next_s <= EXECUTE;

    when WAIT_FOR_DATA =>
        print(str(to_integer(unsigned(identifier))) & " WAITING FOR DATA: ");
        next_s <= READ_DATA_1;

    when SLEEP =>
      print(str(to_integer(unsigned(identifier))) & " SLEEP: " & str(sleep_counter));
      if sleep_counter > 1 then
        next_s <= IDLE;
        sleep_counter := 1;
      else
        sleep_counter := sleep_counter + 1;
      end if;

    when SHORT_SLEEP =>
      print(str(to_integer(unsigned(identifier))) & " SLEEP");
      next_s <= IDLE;

    when SEND_DATA =>
      print(str(to_integer(unsigned(identifier))) & " SEND_DATA");
      long_mute <= '0';
      short_mute <= '0';
      sending <= '1';
      next_s <= IDLE;

    when EXECUTE =>
        print(str(to_integer(unsigned(identifier))) & " EXECUTE");
        case current_cmd is
    			when ADD =>
            result_reg <= std_logic_vector(unsigned(acc1) + unsigned(acc2));
    			when CRC =>
            result_reg <= nextCRC(acc1, acc2);
          when SUB =>
            result_reg <= std_logic_vector(unsigned(acc1) - unsigned(acc2));
          when NOP =>
            result_reg <= result_reg;
          when ID =>
            result_reg <= result_reg;
          when DATA_REQ =>
            result_reg <= result_reg;
          when COM =>
            next_s <= SET_ADD;
          when INC =>
          result_reg <= std_logic_vector(unsigned(acc1) + 1);
    		end case;

        if current_cmd /= COM then
          next_s <= IDLE;
        end if;


    when SET_ADD =>
        print(str(to_integer(unsigned(identifier))) & " SET_ADD");
        result_reg <= acc2;
        sending <= '1';
        next_s <= SET_CMD;

    when SET_CMD =>
        print(str(to_integer(unsigned(identifier))) & " SET_CMD");
        result_reg <= "10010000";
        sending <= '1';
        next_s <= SET_SLP;
    when SET_SLP =>
        print(str(to_integer(unsigned(identifier))) & " SET_SLP");
        sending <= '0';
        long_mute <= '1';
        next_s <= SET_OPR;
    when SET_OPR =>
        print(str(to_integer(unsigned(identifier))) & " SET_OPR");
        if sending = '0' then
          next_s <= SET_OPR;
        else
          next_s <= IDLE;
        end if;
        result_reg <= acc1;
        sending <= '1';
        long_mute <= '0';

    when others =>
		vstate <= "111111";

    end case;
end process;


-- tri-state bus
conn_bus <= result_reg when sending = '1' else "ZZZZZZZZ";
conn_bus <= "11111110" when short_mute = '1' else "ZZZZZZZZ";
conn_bus <= "11111111" when long_mute = '1' else "ZZZZZZZZ";
-- output debugging signals
state <= vstate;
vq    <= q;
with current_cmd select
 vcurrent_cmd <= "0001" when ADD,
					  "0010" when ID,
					  "0011" when CRC,
					  "0100" when DATA_REQ,
					  "0000" when others;


end Behavioral;
