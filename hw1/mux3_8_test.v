`include "templates.v"

module adder8_test();
  localparam CONTROL_WIDTH = 3;
  localparam DATA_WIDTH = 8;

  reg [DATA_WIDTH - 1:0] d [0:(1 << CONTROL_WIDTH) - 1];
  reg [CONTROL_WIDTH - 1:0] a;
  wire [DATA_WIDTH - 1:0] out;

  integer i, j, k;
  reg err_flag = 0;

  mux_3_8 mux_3_8_to_test (d[0], d[1], d[2], d[3], d[4], d[5], d[6], d[7], a, out);

  initial begin
    for (i = 0; i < 1 << CONTROL_WIDTH; i = i + 1) begin
      for (j = 0; j < 1 << DATA_WIDTH; j = j + 1) begin
        a = i;
        d[i] = j;
        for (k = 0; k < 1 << DATA_WIDTH; k = k + 1) begin
            if (k != i) d[k] = 'x;
        end
        #1;
        if (out !== d[i]) begin
          $display("Error: a=%d, d[%d]=%d, out=%d", a, i, d[i], out);
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
