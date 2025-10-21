// structural.v

// Реализация логического вентиля NOT с помощью структурных примитивов
module not_gate(in, out);
  // Входные порты помечаются как input, выходные как output
  input wire in;
  output wire out;
  // Ключевое слово wire для обозначения типа данных можно опустить,
  // тогда оно подставится неявно, например:
  /*
    input in;
    output out;
  */

  supply1 vdd; // Напряжение питания
  supply0 gnd; // Напряжение земли

  // p-канальный транзистор, сток = out, исток = vdd, затвор = in
  pmos pmos1(out, vdd, in); // (сток, исток, база)
  // n-канальный транзистор, сток = out, исток = gnd, затвор = in
  nmos nmos1(out, gnd, in);
endmodule

// Реализация NAND с помощью структурных примитивов
module nand_gate(in1, in2, out);
  input wire in1;
  input wire in2;
  output wire out;

  supply0 gnd;
  supply1 pwr;

  // С помощью типа wire можно определять промежуточные провода для соединения элементов.
  // В данном случае nmos1_out соединяет сток транзистора nmos1 и исток транзистора nmos2.
  wire nmos1_out;

  // 2 p-канальных и 2 n-канальных транзистора
  pmos pmos1(out, pwr, in1);
  pmos pmos2(out, pwr, in2);
  nmos nmos1(nmos1_out, gnd, in1);
  nmos nmos2(out, nmos1_out, in2);
endmodule

// Реализация NOR с помощью структурных примитивов
module nor_gate(in1, in2, out);
  input wire in1;
  input wire in2;
  output wire out;

  supply0 gnd;
  supply1 pwr;

  // Промежуточный провод, чтобы содединить сток pmos1 и исток pmos2
  wire pmos1_out;

  pmos pmos1(pmos1_out, pwr, in1);
  pmos pmos2(out, pmos1_out, in2);
  nmos nmos1(out, gnd, in1);
  nmos nmos2(out, gnd, in2);
endmodule

// Реализация AND с помощью NAND и NOT
module and_gate(in1, in2, out);
  input wire in1;
  input wire in2;
  output wire out;

  // Промежуточный провод, чтобы передать выход вентиля NAND на вход вентилю NOT
  wire nand_out;

  // Схема для формулы AND(in1, in2) = NOT(NAND(in1, in2))
  nand_gate nand_gate1(in1, in2, nand_out);
  not_gate not_gate1(nand_out, out);
endmodule

// Реализация OR с помощью NOR и NOT
module or_gate(in1, in2, out);
  input wire in1;
  input wire in2;
  output wire out;

  wire nor_out;

  // Схема для формулы OR(in1, in2) = NOT(NOR(in1, in2))
  nor_gate nor_gate1(in1, in2, nor_out);
  not_gate not_gate1(nor_out, out);
endmodule

// Реализация XOR с помощью NOT, AND, OR
module xor_gate(in1, in2, out);
  input wire in1;
  input wire in2;
  output wire out;

  wire not_in1;
  wire not_in2;

  wire and_out1;
  wire and_out2;

  wire or_out1;

  // Формула: XOR(in1, in2) = OR(AND(in1, NOT(in2)), AND(NOT(in1), in2))

  not_gate not_gate1(in1, not_in1);
  not_gate not_gate2(in2, not_in2);

  and_gate and_gate1(in1, not_in2, and_out1);
  and_gate and_gate2(not_in1, in2, and_out2);

  or_gate or_gate1(and_out1, and_out2, out);
endmodule

// Полусумматор
module half_adder(a, b, c_out, s);
  input wire a;
  input wire b;
  output wire c_out;
  output wire s;

  /*
    Таблица истинности для полусумматора
    a b | c_out | s
    0 0 | 0     | 0
    0 1 | 0     | 1
    1 0 | 0     | 1
    1 1 | 1     | 0
  */

  // c_out вычисляется как AND от a и b
  and_gate and_gate1(a, b, c_out);

  // s вычисляется как XOR от a и b
  xor_gate xor_gate1(a, b, s);
endmodule

module adder8(op1, op2, sum, cout);
  // 8-битные операнды
  input [7:0] op1, op2;
  // 8-битная сумма
  output [7:0] sum;
  // Флаг переноса
  output cout;
  
  wire [7:0] carry;
  
  half_adder ha0(op1[0], op2[0], carry[0], sum[0]);
  
  genvar i;
  generate
    for (i = 1; i < 8; i = i + 1) begin
      wire w1, w2, w3;
      half_adder ha1(op1[i], op2[i], w1, w2);
      half_adder ha2(w2, carry[i - 1], w3, sum[i]);
      or_gate or1(w1, w3, carry[i]);
    end
  endgenerate
  
  assign cout = carry[7];
endmodule

module mux_2_1(in0, in1, sel, out);
  input in0, in1, sel;
  output out;
  
  wire not_sel, and0_out, and1_out;
  
  not_gate not1(sel, not_sel);
  and_gate and0(in0, not_sel, and0_out);
  and_gate and1(in1, sel, and1_out);
  or_gate or1(and0_out, and1_out, out);
endmodule

module mux_3_8(d0, d1, d2, d3, d4, d5, d6, d7, a, out);
  // Verilog не поддерживает массивы входов/выходов :(
  // поэтому мы явно перечисляем 8 входов
  input [7:0] d0, d1, d2, d3, d4, d5, d6, d7; // 8 входных 8-битных сигналов данных
  input [2:0] a; // 3-битный управляющий сигнал
  output [7:0] out; // 8-битный выход
  
  wire [7:0] mux0_out, mux1_out, mux2_out, mux3_out;
  wire [7:0] mux4_out, mux5_out;
  
  genvar i;
  generate
    for (i = 0; i < 8; i = i + 1) begin : mux_level1
      mux_2_1 mux0(d0[i], d1[i], a[0], mux0_out[i]);
      mux_2_1 mux1(d2[i], d3[i], a[0], mux1_out[i]);
      mux_2_1 mux2(d4[i], d5[i], a[0], mux2_out[i]);
      mux_2_1 mux3(d6[i], d7[i], a[0], mux3_out[i]);
    end
    
    for (i = 0; i < 8; i = i + 1) begin : mux_level2
      mux_2_1 mux4(mux0_out[i], mux1_out[i], a[1], mux4_out[i]);
      mux_2_1 mux5(mux2_out[i], mux3_out[i], a[1], mux5_out[i]);
    end
    
    for (i = 0; i < 8; i = i + 1) begin : mux_level3
      mux_2_1 mux6(mux4_out[i], mux5_out[i], a[2], out[i]);
    end
  endgenerate
endmodule



module alu(op1, op2, control, result);
  // 8-битные операнды
  input [7:0] op1, op2;
  // 3-битный управляющий сигнал
  input [2:0] control;
  output [7:0] result;
  wire [7:0] add_result, sub_result, slt_result, and_result, or_result, not_and_result, not_or_result;
  wire cout;
  
  adder8 adder(op1, op2, add_result, cout);
  
  genvar i;
  generate
    for (i = 0; i < 8; i = i + 1) begin
      and_gate and_gate(op1[i], op2[i], and_result[i]);
      not_gate not_gate_and(and_result[i], not_and_result[i]);
      or_gate or_gate(op1[i], op2[i], or_result[i]);
      not_gate not_gate_or(or_result[i], not_or_result[i]);
    end
  endgenerate
  
  mux_3_8 output_mux(
    and_result,
    not_and_result,
    or_result,
    not_or_result,
    add_result,
    sub_result,
    slt_result,
    {8{1'b0}},
    control,
    result
  );

endmodule