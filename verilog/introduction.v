/*

Код на верилоге состоит из модулей. Модуль соответствует отдельному устройству в схеме.

Общий формат модуля:
module <имя>(<названия портов для взаимодействия с остальными модулями>);
  <объявления типов для портов, указанных в заголовке>
  <объявления внутренних переменных (variables)>
  <инстанциация внутренних модулей>
  <объявления цепей (nets) и примитивов структурного моделирования>

  // Блок initial (может быть несколько). Код внутри блока запускается при
  // инстанциации модуля и отрабатывает один раз.
  initial begin
    <код>
  end

  // Блок always (может быть несколько). Код внутри блока запускается при
  // каждом событии.
  always <событие> begin
    <код>
  end

  // Все блоки initial и always запускаются параллельно, независимо друг от друга.
endmodule

// Модуль с параметрами
module <имя> #(parameter [<имя_параметра> = <значение_по_умолчанию>])
  (<названия портов для взаимодействия с остальными модулями>);
...
endmodule
*/


// Базовый пример модуля
module hello_world();
  initial begin
    // Системная функция $display выводит текст на экран во время симуляции.
    $display("Hello world");
  end
endmodule


// Часть 1. Переменные и литералы

module data_types();
  // Объявление переменных
  reg r1; // Хранит один бит: 0 или 1 или x или z (скаляр)
  reg [7:0] r2; // 8-битное беззнаковое число (вектор)
  reg signed [7:0] r3; // 8-битное число со знаком в представлении дополнения до 2 (вектор со знаком)
  reg signed [31:0] r4; // 32-битное число со знаком
  integer i1; // Целочисленная переменная общего назначения
  time t1; // reg [63:0]
  wire w1; // Не хранит внутри себя значение (сигнал на проводе имеет значение z, если провод не подключен)
  reg signed [31:0] integer_array [0:7]; // Массив из 8 32-битных знаковых чисел

  assign w1 = r1;

  // Все переменные должны быть объявлены в начале модуля, внутри блока initial объявления не разрешены.

  initial begin
    $display("Scalar reg");
    $display("0. r1 = %0d, w1 = %0d", r1, w1);
    // Переменная типа reg может принимать два значения
    r1 = 0;
    $display("1. r1 = %0d, w1 = %0d", r1, w1); // Спецификатор %0d заменяется на значение r1
    r1 = 1;
    $display("2. r1 = %0d", r1);

    $display("Vector reg");
    r2 = 8'b10001011; // Двоичное представление числа 139
    // Общая форма двоичного литерала: <количество бит> 'b <значения бит>
    $display("1. r2 = %0d", r2);
    $display("2. r2 (bin) = %b", r2); // Спецификатор %b выводит двоичное представление
    r2 = 139;
    $display("3. r2 = %0d", r2);

    $display("Signed vector reg");
    r3 = 8'b10001011; // Число -117 в дополнении до двух
    $display("1. r3 = %0d", r3);
    $display("2. r3 (bin) = %b", r3);
    r3 = -117;
    $display("3. r3 = %0d", r3);

    // Не компилируется:
    // w1 = 1
  end
endmodule

module string_literal();
  reg [8*11-1:0] str;

  initial begin
    // Строки хранятся в векторе длиной 8 * (длина строки)
    str = "Hello world";
    $display("%s", str);
  end
endmodule


// Часть 2. Выражения

module expressions();
  reg signed [7:0] r1, r2;
  reg [3:0] r5, r6;

  initial begin

    // Арифметические операции
    $display("Arithmetical operations");
    r1 = 8'd22;
    // r1 = 22;
    r2 = 8'd3;
    $display("r1 = %0d", r1);
    $display("r2 = %0d", r2);
    $display("r1 + r2 = %0d", r1 + r2);
    $display("r1 - r2 = %0d", r1 - r2);
    $display("r2 - r1 = %0d", r2 - r1);
    $display("r1 * r2 = %0d", r1 * r2);
    $display("r1 / r2 = %0d", r1 / r2);
    $display("r1 %% r2 = %0d", r1 % r2);
    $display("r2 ** 4 = %0d", r2 ** 4);

    // ! signed arithmetics

    // Побитовые операции
    $display("Bitwise operators");
    r5 = 4'd6;
    r6 = 4'd3;
    $display("r5 (bin) = %b", r5);
    $display("r6 (bin) = %b", r6);
    $display("~r5      = %b", ~r5);
    $display("r5 & r6  = %b", r5 & r6);
    $display("r5 | r6  = %b", r5 | r6);
    $display("r5 ^ r6  = %b", r5 ^ r6);

    // Операции сдвига
    $display("Shift operators");
    r1 = 8'd22;
    $display("r1       = (binary) %b", r1);
    $display("r1 << 2  = (binary) %b", r1 << 2);
    $display("r1 >> 2  = (binary) %b", r1 >> 2);
    $display("r1 >>> 2 = (binary) %b", r1 >>> 2);

    // Унарные операции редукции
    $display("Unary reduction operators");
    $display("r1  = (binary) %b", r1);
    $display("&r1 = (binary) %b", &r1); // &(6'b010100) = 0&1&0&1&0&0
    $display("|r1 = (binary) %b", |r1);
    $display("^r1 = (binary) %b", ^r1);
    $display("^~r1 = (binary) %b", ^~r1);

    // Логические операции
    $display("Logical operators");
    $display("1 && 0 = %b", 1 && 0);
    $display("1 || 0 = %b", 1 || 0);
    $display("!1 = %b", !1);

    // Сравнение на равенство
    $display("Equality operators");
    r1 = 8'd4;
    r2 = 8'd5;
    $display("r1 = %0d", r1);
    $display("r2 = %0d", r2);
    $display("(r1 == r1) = %b", r1 == r1);
    $display("(r1 == r2) = %b", r1 == r2);
    $display("(r1 != r2) = %b", r1 != r2);

    // Сравнение на меньше/больше
    $display("Relational operators");
    r1 = 8'd54;
    r2 = 8'd89;
    $display("r1 = %0d", r1);
    $display("r2 = %0d", r2);
    $display("(r1 < r2)  = %b", r1 < r2);
    $display("(r1 <= r2) = %b", r1 <= r2);
    $display("(r1 > r2)  = %b", r1 > r2);
    $display("(r1 >= r2) = %b", r1 >= r2);

    // Конкатенация, репликация и срезы
    $display("Concatenation operator");
    r5 = 4'b1001;
    r6 = 4'b0011;
    $display("r5           = %b", r5);
    $display("r6           = %b", r6);
    $display("{r5, r6}     = %b", {r5, r6});
    $display("{r6, r6, r6} = %b", {r6, r6, r6});
    $display("{3{r6}}      = %b", {3{r6}}); // Репликация вектора
    $display("Slice");
    $display("{r5[3:1]}    = %b", r5[3:1]);
  end
endmodule


// Часть 3. Управляющие конструкции

module statements();
  reg [7:0] r1, r2;
  integer i, s;

  

  initial begin
    // Условный оператор
    $display("'if' statement");
    r1 = 12;
    r2 = 12;
    if (r1 > r2) begin
      $display("r1 is greater");
    end
    else if (r1 < r2) begin
      $display("r2 is greater");
    end
    else begin
      $display("r1 and r2 are equal");
    end

    // Цикл for
    $display("'for' statement");
    for (r1 = 0; r1 < 5; r1 = r1 + 1) begin
      for (r2 = 0; r2 < 5; r2 = r2 + 1) begin
        $display("%0d * %0d = %0d", r1, r2, r1 * r2);
      end
    end

    // Цикл while
    $display("'while' statement");
    i = 0;
    s = 1115;
    while (i ** 2 <= s) begin
      $display("i = %0d, i ** 2 = %0d", i, i ** 2);
      i = i + 1;
    end
    // case
    $display("'case' statement");
    r1 = 3;
    case (r1)
      1: $display("r1 is 1");
      2: $display("r1 is 2");
      3: $display("r1 is 3");
      default: $display("r1 is not 1, 2 or 3");
    endcase
  end
endmodule

// Часть 4. Избегаем boilerplate

module adder_with_parameter #(
  // Параметр со стандартным значением
  parameter WIDTH = 8
) (a, b, sum, carry_out);
  input wire [WIDTH - 1:0] a, b;
  output wire [WIDTH - 1:0] sum;
  output wire carry_out;

  // function <тип результата> <имя>;
  function [WIDTH:0] add;
    input [WIDTH - 1:0] a1, a2;
    begin
      add = a1 + a2;
    end
  endfunction

  // assign <куда> = <комбинация аргументов с помощью функций>
  assign {carry_out, sum} = add(a, b);
endmodule

module adder_with_parameter_testbench();
  reg [7:0] a8, b8;
  wire [7:0] sum8;
  wire carry_out8;

  reg [15:0] a16, b16;
  wire [15:0] sum16;
  wire carry_out16;

  adder_with_parameter adder8 (a8, b8, sum8, carry_out8);
  adder_with_parameter #(16) adder16 (a16, b16, sum16, carry_out16);

  initial begin
    a8 = 100; b8 = 155;
    a16 = 30000; b16 = 40000;
    #1;
    $display("8-bit: %0d + %0d = %0d, carry_out = %b", a8, b8, sum8, carry_out8);
    $display("16-bit: %0d + %0d = %0d, carry_out = %b", a16, b16, sum16, carry_out16);
    a8 = 25; b8 = 10;
    #1;
    $display("8-bit: %0d + %0d = %0d, carry_out = %b", a8, b8, sum8, carry_out8);
  end
endmodule

module and_with_parameter #(
  parameter WIDTH = 8
) (a, b, y);
  input wire [WIDTH-1:0] a, b;
  output wire [WIDTH-1:0] y;
  // Генерация boilerplate'а с помощью genvar и generate
  genvar i;
  generate
    for (i = 0; i < WIDTH; i = i + 1)
      assign y[i] = a[i] & b[i];
  endgenerate
endmodule

module and_with_parameter_testbench();
  reg [7:0] a8, b8;
  wire [7:0] y8;

  reg [15:0] a16, b16;
  wire [15:0] y16;

  and_with_parameter #(8) and8 (a8, b8, y8);
  and_with_parameter #(.WIDTH(16)) and16 (a16, b16, y16);

  initial begin
    a8 = 8'b10101010; b8 = 8'b11001100;
    a16 = 16'b1010101010101010; b16 = 16'b1100110011001100;
    #1
    $display("8-bit: %b & %b = %b", a8, b8, y8);
    $display("16-bit: %b & %b = %b", a16, b16, y16);
  end
endmodule


// Часть 5. Управление временем

module delay_control();
  reg [7:0] r1, r2;

  // Специальный код для сохранения сигналов в файл
  initial begin
    $dumpfile("./dump.vcd");
    $dumpvars;
  end

  // Блок 1
  initial begin
    $display("Block 1 started");
    r1 = 10;
    $display("t=%0t: set r1 to %0d", $time, r1);
    // Оператор #N ждет N временных единиц перед продолжением исполнения
    #5 r1 = 11;
    $display("t=%0t: set r1 to %0d", $time, r1);
    #7 r1 = 12;
    $display("t=%0t: Set r1 to %0d", $time, r1);
    #3 r1 = 13;
    $display("t=%0t: Set r1 to %0d", $time, r1);
  end

  // Блок 2
  initial begin
    $display("Block 2 started");
    r2 = 30;
    $display("t=%0t: Set r2 to %0d", $time, r2);
    #10 r2 = 31;
    $display("t=%0t: Set r2 to %0d", $time, r2);
    #5 r2 = 32;
    $display("t=%0t: Set r2 to %0d", $time, r2);
    #1;
    $finish;
  end

  // Блок 3
  initial begin
    $display("Block 3 started");
    // Оператор @(<переменная>) ждет, пока переменная не поменяет значение
    @(r1) $display("Block 3: r1 changed to %0d, t=%0t", r1, $time);
  end

  always @(r1 or r2) begin
    $display("Always: r1 = %0d, r2 = %0d, t=%0t", r1, r2, $time);
  end

  // Always срабатывает каждые 5 временных интервалов
  always #5 begin
    $display("Always #5: t=%0t", $time);
  end
endmodule


// Пример: 3-битный счетчик

module counter();
  reg c;
  reg [2:0] count = 0;
  integer i;

  // Специальный код для сохранения сигналов в файл, файл можно открыть с помощью GTK Wave
  initial begin
    $dumpfile("./dump.vcd");
    $dumpvars;
  end

  initial begin
    c = 0;

    // 20 раз переключить тактовый вход c
    for (i = 0; i < 20; i = i + 1) begin
      #1 c = !c;
    end
  end

  // Событие 'posedge' означает дождаться фронта сигнала
  // (изменение с 0 на 1)
  // negedge -- с 1 на 0
  always @(posedge c) begin
    count = count + 1;
  end
endmodule

