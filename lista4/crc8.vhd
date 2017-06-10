library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.pack.all;

entity crc8 is
    port(
        clk         :in  std_logic;
        data_in     :in  std_logic_vector (7 downto 0);
        crc_out     :out std_logic_vector (7 downto 0)
    );
end crc8;

architecture Behavioral of crc8 is
    signal newCRC : std_logic_vector(7 downto 0) := (others => '0');
begin

    process (clk, data_in, newCRC)
    begin
      if clk = '1' and rising_edge(clk) then
	        newCRC <= nextCRC(data_in, newCRC);
	    end if;

    end process;

    crc_out <= newCRC;

end Behavioral;
