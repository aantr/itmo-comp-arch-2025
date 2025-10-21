`include "templates.v"

module alu_test();
  localparam DATA_WIDTH = 8;

  reg signed [DATA_WIDTH - 1:0] op1, op2;
  reg [2:0] control;
  wire signed [DATA_WIDTH - 1:0] result;

  integer i, j;
  reg err_flag = 0;

  reg signed [DATA_WIDTH - 1:0] expected_result;

  alu alu_to_test(op1, op2, control, result);

  initial begin
    for (control = 0; control < 7; control = control + 1) begin
      for (i = -(1 << (DATA_WIDTH - 1)); i < (1 << (DATA_WIDTH - 1)); i = i + 1) begin
        for (j = -(1 << (DATA_WIDTH - 1)); j < (1 << (DATA_WIDTH - 1)); j = j + 1) begin
          op1 = i;
          op2 = j;
          #1;
          case (control)
            3'b000: expected_result = op1 & op2;
            3'b001: expected_result = ~(op1 & op2);
            3'b010: expected_result = op1 | op2;
            3'b011: expected_result = ~(op1 | op2);
            3'b100: expected_result = op1 + op2;
            3'b101: expected_result = op1 - op2;
            3'b110: expected_result = (op1 < op2) ? 8'd1 : 8'd0;
            default: expected_result = 0; // unused
          endcase
          if (result !== expected_result) begin
            err_flag = 1;
            $display("Error: control=%b, op1=%d, op2=%d, expected=%d, got=%d", control, op1, op2, expected_result, result);
          end
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
