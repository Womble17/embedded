LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
Use work.txt_util.ALL;
entity crc8_tb is
end crc8_tb;

architecture behavior of crc8_tb is
    -- main component counting CRC sums
    component crc8
    port(
        clk     :in     std_logic;
        data_in :in     std_logic_vector(7 downto 0);
        crc_out :out    std_logic_vector(7 downto 0)
    );
    end component;

    -- component delcaration for ROM look-up
	component rom_for_crc8
    port(
        address  :in  std_logic_vector(2 downto 0);
        data_out :out std_logic_vector(7 downto 0)
	  );
	 end component;

   signal clk :std_logic := '0';
   constant clk_period :time := 20 ns;

   signal data_in :std_logic_vector(7 downto 0) := (others => '0');
   signal crc_out :std_logic_vector(7 downto 0);

	  -- ROM
    -- output data
    signal data_out_a0 :std_logic_vector(7 downto 0);
	  signal data_out_66 :std_logic_vector(7 downto 0);

    -- access address
    signal address :std_logic_vector(2 downto 0) := (others => '0');


BEGIN
    -- Instantiate the Unit Under Test (UUT)
    uut: crc8 PORT MAP (
        clk => clk,
        data_in => data_in,
        crc_out => crc_out
    );

    -- instance of ROM lookup for constant X"a0" input
	rom_a0 : entity work.rom_for_crc8(const_a0)
	port map (
	    address => address,
	    data_out => data_out_a0
	);

    -- instance of ROM lookup for constant X"66" input
	rom_66 : entity work.rom_for_crc8(const_66)
	port map (
	    address => address,
        data_out => data_out_66
	);

    -- Clock process definitions
    clk_process :process
	variable wait_done :natural := 0;
    begin
	    if wait_done = 0 then
		    wait for clk_period * 0.2;
			wait_done := 1;
	    end if;

        clk <= '1';
		wait for clk_period / 2;
		clk <= '0';
        wait for clk_period / 2;

    end process;

    -- Stimulus process
    stim_proc: process
    begin

    -- init datain
    data_in <= X"a0";

    -- for each addr do
    for i in 0 to 7 loop
        address <= std_logic_vector(to_unsigned(i, address'length));
        wait on clk until falling_edge(clk);

	print(str(i) & " " & str(crc_out));
        assert crc_out = data_out_a0
            report "[ASSERT]bad crc a0" severity error;
    end loop;

    data_in <= data_out_a0;
    wait on clk until falling_edge(clk);


    data_in <= X"66";

    for i in 0 to 7 loop
        address <= std_logic_vector(to_unsigned(i, address'length));
        wait on clk until falling_edge(clk);
        assert crc_out = data_out_66
            report "[ASSERT]bad crc 66" severity error;
    end loop;

    -- Set CRC to 0x00
    data_in <= data_out_66;
    wait on clk until falling_edge(clk);

    wait;
    end process;

END;
