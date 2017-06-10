

entity adder is
  -- `i0`, `i1` and the carry-in `ci` are inputs of the adder.
  -- `s` is the sum output, `co` is the carry-out.
  port (
	i0, i1, i2 : in bit; 
	out1, out2 : out bit
	);
end adder;

architecture rtl of adder is
	signal tmp1, tmp2 : bit;
begin
   --  This full-adder architecture contains two concurrent assignment.
   --  Compute the sum.
	tmp1 <= i0 and i1;
	tmp2 <= i1 or i2;

   --  Compute the carry.
	out1 <= tmp1 nor tmp2;
	out2 <= tmp1 xor tmp2;
end rtl;
