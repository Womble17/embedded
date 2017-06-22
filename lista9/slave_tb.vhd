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
           debug        : in    STD_LOGIC;
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

    COMPONENT AC
    Port (
           clk          : in    STD_LOGIC;
           ac_in        : in    STD_LOGIC_VECTOR (15 downto 0);
           ac_out       : out   STD_LOGIC_VECTOR (15 downto 0);
           bus_data     : inout STD_LOGIC_VECTOR (15 downto 0)
      );
    END COMPONENT;

    COMPONENT ALU
    Port (
           clk          : in    STD_LOGIC;
           alu_in       : in    STD_LOGIC_VECTOR (15 downto 0);
           alu_out      : out   STD_LOGIC_VECTOR (15 downto 0);
           bus_data     : inout STD_LOGIC_VECTOR (15 downto 0)
      );
    END COMPONENT;

    COMPONENT OUTREG
    Port (
           clk          : in    STD_LOGIC;
           bus_data     : inout STD_LOGIC_VECTOR (15 downto 0)
      );
    END COMPONENT;

    COMPONENT controller
    Port (
           clk          : in    STD_LOGIC;
           bus_data     : inout STD_LOGIC_VECTOR (15 downto 0)
      );
    END COMPONENT;

    COMPONENT INREG
    Port (
           clk          : in    STD_LOGIC;
           bus_data     : inout STD_LOGIC_VECTOR (15 downto 0);
           clk_run      : inout STD_LOGIC
      );
    END COMPONENT;


   --Inputs
   signal clk           : std_logic := '0';
   signal clk_run       : std_logic := '1';
   signal debug         : std_logic := '0';
   signal ram_mar       : std_logic_vector(4 downto 0) := (others => '0');
   signal bus_data      : std_logic_vector(15 downto 0) := (others => '0');
   signal alu_in_ac_out : std_logic_vector(15 downto 0) := (others => '1');
   signal alu_out_ac_in : std_logic_vector(15 downto 0) := (others => '1');

   -- Clock period definitions
   constant clk_period : time := 100 ns;

BEGIN

	-- Instantiate the Unit Under Test (UUT)
  memory: RAM
	PORT MAP (
    ram_mar => ram_mar,
		clk => clk,
    debug => debug,
		bus_data => bus_data
  );

  address_reg : MAR
  PORT MAP (
    ram_mar => ram_mar,
    clk => clk,
    bus_data => bus_data
  );

  output_reg : OUTREG
  PORT MAP (
    clk => clk,
    bus_data => bus_data
  );

  input_reg : INREG
  PORT MAP (
    clk => clk,
    clk_run => clk_run,
    bus_data => bus_data
  );

  control_unit : controller
  PORT MAP (
    clk => clk,
    bus_data => bus_data
  );

  accumulator_reg : AC
  PORT MAP (
    ac_in => alu_out_ac_in,
    ac_out => alu_in_ac_out,
    clk => clk,
    bus_data => bus_data
  );

  arithmetic_logic_unit : ALU
  PORT MAP (
    alu_in => alu_in_ac_out,
    alu_out => alu_out_ac_in,
    clk => clk,
    bus_data => bus_data
  );

   -- Clock process definitions
   clk_process :process
   begin
    --if clk_run = '1' then
     clk <= '0';
    --end if;
		 wait for clk_period/2;

    --if clk_run = '1' then
     clk <= '1';
    --end if;
     wait for clk_period/2;
   end process;


   -- Stimulus process
   stim_proc: process
   begin
      wait for 200 ns;
      bus_data <= "0111111111111111";
      wait for clk_period;
      bus_data <= "ZZZZZZZZZZZZZZZZ";

      wait;
   end process;

END;
