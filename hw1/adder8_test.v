`include "templates.v"

module adder8_test();
  reg [7:0] op1, op2;
  wire [7:0] sum;
  wire cout;

  integer i, j;
  reg err_flag = 0;

  localparam WIDTH = 3;

  adder8 adder8_to_test (op1, op2, sum, cout);

  initial begin
    for (i = 0; i < 1 << WIDTH; i = i + 1) begin
      for (j = 0; j < 1 << WIDTH; j = j + 1) begin
        op1 = i;
        op2 = j;
        #1;
        if ({cout, sum} !== (op1 + op2)) begin
          $display("Error: %d + %d != %d (cout=%b)", op1, op2, sum, cout);
          err_flag = 1;
        end
      end
    end
    if (!err_flag) begin
      $display("All tests passed successfully.");
    end else begin
      $display("Some tests failed.");
    end
    $finish;
  end
endmodule
