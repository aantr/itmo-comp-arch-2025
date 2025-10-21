`include "structural.v"

module testbench();
  reg a = 0;
  reg b = 0;
  wire not_result;
  wire nand_result;
  wire and_result, or_result, xor_result;
  wire s, c_out;

  not_gate not_g1(a, not_result);
  nand_gate nand_g1(a, b, nand_result);
  and_gate and_g1(a, b, and_result);
  or_gate or_g1(a, b, or_result);
  xor_gate xor_g1(a, b, xor_result);
  half_adder ha(a, b, s, c_out);

  initial begin
    //$monitor("a = %b, b = %b, and_result = %b, or_result = %b, xor_result = %b", a, b, and_result, or_result, xor_result);
    $monitor("a = %b, b = %b, s = %b, c_out = %b", a, b, s, c_out);
    #5 a = 1; b = 0;
    #5 a = 0; b = 1;
    #5 a = 1; b = 1;
  end
endmodule