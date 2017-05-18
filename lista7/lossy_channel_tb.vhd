
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
Use work.txt_util.ALL;

ENTITY lossy_channel_tb IS
END lossy_channel_tb;

ARCHITECTURE behavior OF lossy_channel_tb IS

    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT decoder
      PORT(
         clk : IN  std_logic;
         work  : in  STD_LOGIC;
         data_in : IN  std_logic_vector(7 downto 0);
         data_out : OUT  std_logic_vector(3 downto 0)
        );
    END COMPONENT;

    COMPONENT encoder
      PORT(
         clk : IN  std_logic;
         work  : in  STD_LOGIC;
         data_in : IN  std_logic_vector(3 downto 0);
         data_out : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;

    COMPONENT lossy_channel
      PORT(
         clk : IN  std_logic;
         work  : in  STD_LOGIC;
         data_in : in  STD_LOGIC_VECTOR (7 downto 0);
         data_out : out  STD_LOGIC_VECTOR (7 downto 0)
        );
    END COMPONENT;

   signal clk : std_logic := '0';
   signal work : std_logic := '0';

   -- channel inputs
   signal data_in          : std_logic_vector(3 downto 0) := (others => '0');
   signal encoder_data_in  : std_logic_vector(3 downto 0) := (others => '0');
   signal decoder_data_in  : std_logic_vector(7 downto 0) := (others => '0');

 	-- channel outputs
   signal data_out          : std_logic_vector(3 downto 0);
   signal encoder_data_out  : std_logic_vector(7 downto 0) := (others => '0');
   signal decoder_data_out  : std_logic_vector(3 downto 0) := (others => '0');
   -- clock period definitions
   constant clk_period : time := 20 ns;

BEGIN

	-- Instantiate the Unit Under Test (UUT)


  enc: encoder
  PORT MAP (
    clk => clk,
    work => work,
    data_in => data_in,
    data_out => encoder_data_out
    );

  lc: lossy_channel
  PORT MAP (
    clk => clk,
    work => work,
    data_in => encoder_data_out,
    data_out => decoder_data_in
    );

  dec: decoder
  PORT MAP (
   clk => clk,
   work => work,
   data_in => decoder_data_in,
   data_out => data_out
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
      -- hold reset state for 100 ns.
      wait for 100 ns;
      work <= '1';

		for i in 0 to 15
		loop
      --wait for clk_period;
      print("in : " & str(std_logic_vector(to_unsigned(i, data_in'length))) & " " & str(i));
			data_in <= std_logic_vector(to_unsigned(i, data_in'length));
      --print("in : " & str(data_in));
      wait for clk_period;
      print("out: " & str(data_out));
print("");
      wait for clk_period;

			  --assert data_in = data_out report "flip " & str(i) & " " & str(data_out);
		end loop;
      wait;
   end process;

END;
