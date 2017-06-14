LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
Use work.txt_util.ALL;
--USE IEEE.std_logic_unsigned.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE ieee.numeric_std.ALL;

ENTITY slave_tb IS
END slave_tb;

ARCHITECTURE behavior OF slave_tb IS

    -- Component Declaration for the Unit Under Test (UUT)

    COMPONENT RAM
    Port (
           clk          : in    STD_LOGIC;
           print_mem    : in    STD_LOGIC;
           ram_mar      : in    STD_LOGIC_VECTOR (4 downto 0);
           bus_data     : inout STD_LOGIC_VECTOR (15 downto 0)
			);
    END COMPONENT;

    COMPONENT MAR
    Port (
           clk          : in    STD_LOGIC;
           ram_mar      : out   STD_LOGIC_VECTOR (4 downto 0);
           bus_data     : inout STD_LOGIC_VECTOR (15 downto 0)
      );
    END COMPONENT;


   --Inputs
   signal clk       : std_logic := '0';
   signal print_mem : std_logic := '0';
   signal ram_mar   : std_logic_vector(4 downto 0) := (others => '0');
   signal bus_data  : std_logic_vector(15 downto 0) := (others => '1');

   -- Clock period definitions
   constant clk_period : time := 20 ns;

BEGIN

	-- Instantiate the Unit Under Test (UUT)
  memory: RAM
	PORT MAP (
    ram_mar => ram_mar,
		clk => clk,
    print_mem => print_mem,
		bus_data => bus_data
  );

  address_reg : MAR
  PORT MAP (
    ram_mar => ram_mar,
    clk => clk,
    bus_data => bus_data
  );


   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;


   -- Stimulus process
   stim_proc: process
   begin
      --bus_data <= "0010000000000000";
      wait for 200 ns;
      --print_mem <= '1';
      bus_data <= "0000100000000000";
      wait for clk_period;

      bus_data <= "ZZZZZZZZZZZZZZZZ";
      wait for clk_period;
      --print(str(to_integer(unsigned(bus_data))));





      wait;
   end process;

END;
