use std.textio.all;
--  A testbench has no ports.
entity adder_tb is
end adder_tb;

architecture behav of adder_tb is
   --  Declaration of the component that will be instantiated.
   component adder
       port (
	i0, i1, i2 : in bit; 
	out1, out2 : out bit
	);
   end component;

   --  Specifies which entity is bound with the component.
   for adder_0: adder use entity work.adder;
   signal i0, i1, i2, out1, out2 : bit;
begin
   --  Component instantiation.
   adder_0: adder port map (i0 => i0, i1 => i1, i2 => i2,
                            out1 => out1, out2 => out2);

   --  This process does the real job.
   process
      type pattern_type is record
         --  The inputs of the adder.
         i0, i1, i2 : bit;
         --  The expected outputs of the adder.
         out1, out2 : bit;
      end record;
      --  The patterns to apply.
      type pattern_array is array (natural range <>) of pattern_type;
      constant patterns : pattern_array :=
        (('0', '0', '0', '1', '0'),
         ('0', '0', '1', '0', '1'),
         ('0', '1', '0', '0', '1'),
         ('0', '1', '1', '0', '1'),
         ('1', '0', '0', '1', '0'),
         ('1', '0', '1', '0', '1'),
         ('1', '1', '0', '0', '0'),
         ('1', '1', '1', '0', '0'));
   begin
      --  Check each pattern.
      for i in patterns'range loop
         --  Set the inputs.
         i0 <= patterns(i).i0;
         i1 <= patterns(i).i1;
         i2 <= patterns(i).i2;
         --  Wait for the results.
         wait for 1 ns;
         --  Check the outputs.
         assert out1 = patterns(i).out1
            report "bad sum value" severity error;
         assert out2 = patterns(i).out2
            report "bad carry out value" severity error;
      end loop;
      assert false report "end of test" severity note;
      --  Wait forever; this will finish the simulation.
      wait;
   end process;
end behav;
