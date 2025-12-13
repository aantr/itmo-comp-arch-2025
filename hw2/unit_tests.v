`include "riscv_cpu.v"
`include "testcases/testcase_count.v"

module unit_tests();
  // Основной код для запуска тестов
  initial begin
    // Файл vcd можно визуализировать через GTKWave или через https://app.surfer-project.org
    $dumpfile("dump_unit_tests.vcd");
    $dumpvars;

    // Чтобы пропустить часть тестов, закомментируйте соответствующие строки
    run_testcases("lw", `testcase_count_lw, test_result_lw);
    run_testcases("sw", `testcase_count_sw, test_result_sw);
    run_testcases("add", `testcase_count_add, test_result_add);
    run_testcases("sub", `testcase_count_sub, test_result_sub);
    run_testcases("and", `testcase_count_and, test_result_and);
    run_testcases("or", `testcase_count_or, test_result_or);
    run_testcases("slt", `testcase_count_slt, test_result_slt);
    run_testcases("beq", `testcase_count_beq, test_result_beq);
    run_testcases("addi", `testcase_count_addi, test_result_addi);
    run_testcases("bne", `testcase_count_bne, test_result_bne);
    run_testcases("blt", `testcase_count_blt, test_result_blt);
    run_testcases("lui", `testcase_count_lui, test_result_lui);
    run_testcases("jal", `testcase_count_jal, test_result_jal);
    run_testcases("jalr", `testcase_count_jalr, test_result_jalr);

    show_test_results();
  end

  riscv_cpu cpu(
    .clk(clk),
    .pc(pc), .pc_new(pc_new), .instruction_memory_a(instruction_memory_a), .instruction_memory_rd(instruction_memory_rd),
    .data_memory_a(data_memory_a), .data_memory_rd(data_memory_rd), .data_memory_we(data_memory_we), .data_memory_wd(data_memory_wd),
    .register_a1(register_a1), .register_a2(register_a2), .register_a3(register_a3), .register_we3(register_we3), .register_wd3(register_wd3), .register_rd1(register_rd1), .register_rd2(register_rd2)
  );

  reg [31:0] inp_pc;
  reg [31:0] inp_instruction_memory_rd, inp_data_memory_rd;
  reg [31:0] inp_register_rd1, inp_register_rd2;

  wire clk = 0;
  wire [31:0] pc = inp_pc;
  wire [31:0] instruction_memory_rd = inp_instruction_memory_rd;
  wire [31:0] data_memory_rd = inp_data_memory_rd;
  wire [31:0] register_rd1 = inp_register_rd1;
  wire [31:0] register_rd2 = inp_register_rd2;

  wire [31:0] pc_new;
  wire data_memory_we;
  wire [31:0] instruction_memory_a, data_memory_a, data_memory_wd;
  wire register_we3;
  wire [4:0] register_a1, register_a2, register_a3;
  wire [31:0] register_wd3;

  reg cpu_input_latch;

  reg [31:0] t_instr, t_instr2, t_pc, t_pc2;
  reg fm1, fm2, fr1, fr2, fr3;
  reg [31:0] t_mem1a, t_mem1v, t_mem1v2, t_mem2v;
  reg [4:0] t_reg1a, t_reg2a, t_reg3a;
  reg [31:0] t_reg1v, t_reg2v, t_reg3v, t_reg3v2, t_reg4v, t_reg5v;
  reg [7:0] t_text_length;
  reg [32*8-1:0] t_text_bytes;

  string t_text_string;

  string test_result_lw = "SKIPPED";
  string test_result_sw = "SKIPPED";
  string test_result_add = "SKIPPED";
  string test_result_sub = "SKIPPED";
  string test_result_and = "SKIPPED";
  string test_result_or = "SKIPPED";
  string test_result_slt = "SKIPPED";
  string test_result_beq = "SKIPPED";
  string test_result_addi = "SKIPPED";
  string test_result_bne = "SKIPPED";
  string test_result_blt = "SKIPPED";
  string test_result_lui = "SKIPPED";
  string test_result_jal = "SKIPPED";
  string test_result_jalr = "SKIPPED";
  integer operations_succeeded = 0;
  integer operations_failed = 0;
  integer operations_skipped = 14;

  always @* begin
    if (cpu_input_latch == 1) begin
      inp_pc = t_pc;
      inp_instruction_memory_rd = (instruction_memory_a == t_pc) ? t_instr : t_instr2;
      inp_data_memory_rd = (data_memory_a == t_mem1a) ? t_mem1v : t_mem2v;
      inp_register_rd1 = (register_a1 == t_reg1a) ? t_reg1v : (register_a1 == t_reg2a) ? t_reg2v : (register_a1 == t_reg3a) ? t_reg3v : t_reg4v;
      inp_register_rd2 = (register_a2 == t_reg1a) ? t_reg1v : (register_a2 == t_reg2a) ? t_reg2v : (register_a2 == t_reg3a) ? t_reg3v : (register_a2 == register_a1) ? t_reg4v : t_reg5v;
    end
  end

  task run_testcases;
    input string instruction_type;
    input integer testcase_count;
    output string test_result;
    reg [`testcase_width-1:0] testcases_raw [0:`testcase_count_max-1];
    integer test_num;
    string testcase_description;
    string testcase_error;
    reg [31:0] got_reg3v2;
    reg [31:0] got_mem1v2;
    reg failed;
    begin
      $readmemh({"testcases/", instruction_type, ".dat"}, testcases_raw, 0, testcase_count - 1);

      test_num = 0;
      failed = 0;

      for (test_num = 0; !failed && (test_num < testcase_count); test_num++) begin
        cpu_input_latch = 0;

        {
          t_pc, t_pc2, t_instr, t_instr2,
          fm1, fm2, t_mem1a, t_mem1v, t_mem1v2, t_mem2v,
          fr1, fr2, fr3, t_reg1a, t_reg1v, t_reg2a, t_reg2v, t_reg3a, t_reg3v, t_reg3v2, t_reg4v, t_reg5v,
          t_text_bytes
        } = testcases_raw[test_num];
        t_text_string = t_text_bytes;

        testcase_description = "<?undefined?>";
        if (fr2 == 1 && t_reg1a < t_reg2a) $sformat(testcase_description, "pc=0x%04h, Instruction=\"%s\", Register[x%0d]=0x%04h, Register[x%0d]=0x%04h", t_pc, t_text_string, t_reg1a, t_reg1v, t_reg2a, t_reg2v);
        else if (fr2 == 1 && t_reg1a > t_reg2a) $sformat(testcase_description, "pc=0x%04h, Instruction=\"%s\", Register[x%0d]=0x%04h, Register[x%0d]=0x%04h", t_pc, t_text_string, t_reg2a, t_reg2v, t_reg1a, t_reg1v);
        else if (fm1 == 0 && fr1 == 1 && (fr2 == 0 || t_reg1a == t_reg2a)) $sformat(testcase_description, "pc=0x%04h, Instruction=\"%s\", Register[x%0d]=0x%04h", t_pc, t_text_string, t_reg1a, t_reg1v);
        else if (fm1 == 1 && fr1 == 0) $sformat(testcase_description, "pc=0x%04h, Instruction=\"%s\", Memory[0x%04h]=0x%04h", t_pc, t_text_string, t_reg1a, t_reg1v, t_mem1a, t_mem1v);
        else if (fm1 == 1 && fr2 == 0) $sformat(testcase_description, "pc=0x%04h, Instruction=\"%s\", Register[x%0d]=0x%04h, Memory[0x%04h]=0x%04h", t_pc, t_text_string, t_reg1a, t_reg1v, t_mem1a, t_mem1v);
        else if (fm1 == 0 && fr1 == 0) $sformat(testcase_description, "pc=0x%04h, Instruction=\"%s\"", t_pc, t_text_string);
        else begin $display("Error: unexpected testcase state"); $finish; end
        $display("> Test %s %0d/%0d: %s", instruction_type, test_num + 1, testcase_count, testcase_description);

        cpu_input_latch = 1;
        #100;

        got_reg3v2 = (register_we3 === 1 && register_a3 === t_reg3a) ? register_wd3 : t_reg3v;
        got_mem1v2 = (data_memory_we === 1 && data_memory_a === t_mem1a) ? data_memory_wd : t_mem1v;

        testcase_error = "";
        if (fr3 == 1 && got_reg3v2 !== t_reg3v2) $sformat(testcase_error, "expected Register[x%0d]=0x%04h, got Register[x%0d]=0x%04h", t_reg3a, t_reg3v2, t_reg3a, got_reg3v2);
        else if (fm2 == 1 && got_mem1v2 !== t_mem1v2) $sformat(testcase_error, "expected Memory[0x%04h]=0x%04h, got Memory[0x%04h]=0x%04h", t_mem1a, t_mem1v2, t_mem1a, got_reg3v2);
        else if (pc_new !== t_pc2) $sformat(testcase_error, "expected pc_new=0x%04h, got pc_new=0x%04h", t_pc2, pc_new);
        else if (fm2 == 0 && data_memory_we === 1) $sformat(testcase_error, "unexpected memory write at address 0x%04h", data_memory_a);
        else if (fr3 == 0 && register_we3 === 1 && register_a3 !== t_reg3a) $sformat(testcase_error, "unexpected modification of register x%0d", register_a3);
        if (testcase_error != "") begin
          $display("ERROR: %s", testcase_error);
          failed = 1;
        end
      end

      operations_skipped -= 1;
      if (failed == 1) begin
        operations_failed += 1;
        $sformat(test_result, "FAILED test %0d/%0d\nInput: %s\nError: %s\n", test_num, testcase_count, testcase_description, testcase_error);
      end else begin
        operations_succeeded += 1;
        $sformat(test_result, "OK, %0d/%0d tests passed", testcase_count, testcase_count);
      end
    end
  endtask

  task show_test_results;
    begin
      $display("> Finished running tests");
      $display("\nTEST RESULTS:");
      $display("lw: %s", test_result_lw);
      $display("sw: %s", test_result_sw);
      $display("add: %s", test_result_add);
      $display("sub: %s", test_result_sub);
      $display("and: %s", test_result_and);
      $display("or: %s", test_result_or);
      $display("slt: %s", test_result_slt);
      $display("beq: %s", test_result_beq);
      $display("addi: %s", test_result_addi);
      $display("bne: %s", test_result_bne);
      $display("blt: %s", test_result_blt);
      $display("lui: %s", test_result_lui);
      $display("jal: %s", test_result_jal);
      $display("jalr: %s", test_result_jalr);
      $display("Total: %0d succeeded, %0d failed, %0d skipped", operations_succeeded, operations_failed, operations_skipped);
    end
  endtask
endmodule
