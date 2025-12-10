module riscv_cpu(clk, pc, pc_new, instruction_memory_a, instruction_memory_rd, data_memory_a, data_memory_rd, data_memory_we, data_memory_wd,
                register_a1, register_a2, register_a3, register_we3, register_wd3, register_rd1, register_rd2);
  
  // сигнал синхронизации
  input clk;
  // текущее значение регистра PC
  inout [31:0] pc;
  // новое значение регистра PC (адрес следующей команды)
  output [31:0] pc_new;
  // we для памяти данных
  output data_memory_we;
  // адреса памяти и данные для записи памяти данных
  output [31:0] instruction_memory_a, data_memory_a, data_memory_wd;
  // данные, полученные в результате чтения из памяти
  inout [31:0] instruction_memory_rd, data_memory_rd;
  // we3 для регистрового файла
  output register_we3;
  // номера регистров
  output [4:0] register_a1, register_a2, register_a3;
  // данные для записи в регистровый файл
  output [31:0] register_wd3;
  // данные, полученные в результате чтения из регистрового файла
  inout [31:0] register_rd1, register_rd2;

   // Сигналы для извлечения полей инструкции
  wire [6:0] opcode;
  wire [4:0] rd, rs1, rs2;
  wire [2:0] funct3;
  wire [6:0] funct7;
  wire [11:0] imm_i;
  wire [11:0] imm_s;
  
  // Извлечение полей инструкции
  assign opcode = instruction_memory_rd[6:0];
  assign rd = instruction_memory_rd[11:7];
  assign rs1 = instruction_memory_rd[19:15];
  assign rs2 = instruction_memory_rd[24:20];
  assign funct3 = instruction_memory_rd[14:12];
  assign funct7 = instruction_memory_rd[31:25];
  
  // Форматы immediate-значений
  assign imm_i = instruction_memory_rd[31:20];  // I-type
  assign imm_s = {instruction_memory_rd[31:25], instruction_memory_rd[11:7]};  // S-type

  reg [31:0] register_wd3_result;
  reg [4:0] rd_result;
  reg [4:0] a1_result, a2_result;
  reg [31:0] pc_new_result;
  reg register_we3_result;
  reg data_memory_we_result;
  reg [31:0] data_memory_a_result;
  reg [31:0] data_memory_wd_result;
  reg [31:0] data_from_mem;

always @(posedge clk) begin
    register_we3_result = 1'b0;
    data_memory_we_result = 1'b0;
    pc_new_result = pc + 4;
    
    a1_result = rs1;
    a2_result = rs2;
    rd_result = rd;
    data_memory_a_result = 32'h00000000;
    data_memory_wd_result = 32'h00000000;
    register_wd3_result = 32'h00000000;
  
    case (opcode)
      7'b0110011: begin
        register_we3_result = 1'b1;
        case ({funct7, funct3})
          {7'b0000000, 3'b000}: begin
            register_wd3_result = register_rd1 + register_rd2;
          end
          {7'b0100000, 3'b000}: begin
            register_wd3_result = register_rd1 - register_rd2;
          end
          {7'b0000000, 3'b111}: begin
            register_wd3_result = register_rd1 & register_rd2;
          end
          {7'b0000000, 3'b110}: begin 
            register_wd3_result = register_rd1 | register_rd2;
          end
          {7'b0000000, 3'b010}: begin 
            register_wd3_result = (register_rd1 < register_rd2) ? 32'h00000001 : 32'h00000000;
          end
          default: begin
            register_wd3_result = 32'h00000000;
          end
        endcase
      end
      
      7'b0010011: begin
        register_we3_result = 1'b1;
        case (funct3)
          3'b000: begin
            register_wd3_result = register_rd1 + {{20{imm_i[11]}}, imm_i};
          end
          default: begin
            register_wd3_result = 32'h00000000;
          end
        endcase
      end
      
      7'b0000011: begin
        case (funct3)
          3'b010: begin
            data_memory_a_result = register_rd1 + {{20{imm_i[11]}}, imm_i};
            register_we3_result = 1'b1;
            register_wd3_result = data_memory_rd;
          end
          default: begin
          end
        endcase
      end
      
      7'b0100011: begin
        case (funct3)
          3'b010: begin
            data_memory_a_result = register_rd1 + {{20{imm_s[11]}}, imm_s};
            data_memory_wd_result = register_rd2;
            data_memory_we_result = 1'b1;
          end
          default: begin
          end
        endcase
      end
      
      default: begin
      end
    endcase
  end
  
  // Адрес памяти инструкций
  assign pc_new = pc_new_result;
  assign instruction_memory_a = pc;
  
  // Управление памятью данных
  assign data_memory_we = data_memory_we_result;
  assign data_memory_a = data_memory_a_result;
  assign data_memory_wd = data_memory_wd_result;
  
  // Управление регистровым файлом
  assign register_we3 = register_we3_result;
  assign register_a1 = a1_result;
  assign register_a2 = a2_result;
  assign register_a3 = rd_result;
  
  // Выбор источника данных для записи в регистровый файл
  // Если read = 1, то данные берутся из памяти, иначе из ALU
  assign register_wd3 = register_wd3_result;

endmodule

/*

// поставить результат 
// поставить адрес
// нужно прочитать
// assign a1_result = register_rd1 + imm;
// assign a2_result = register_rd1 + imm;
// funct3 = 1;
// register_rd1;

*/