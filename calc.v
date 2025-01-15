module calc(
  input clk,
  input btnc,
  input btnl,
  input btnu,
  input btnr,
  input btnd,
  input [15:0] sw,
  output [15:0] led
  );

  reg [15:0] accumulator;
  wire [31:0] alu_result;
  wire [31:0] op1 = {{16{accumulator[15]}}, accumulator};
  wire [31:0] op2 = {{16{sw[15]}}, sw};
  wire [3:0] alu_op;
  
  calc_enc CALC_ENC(
    .btnl(btnl),
    .btnc(btnc),
    .btnr(btnr),
    .alu_op(alu_op)
  );
  
  alu ALU(
    .op1(op1),
    .op2(op2),
    .alu_op(alu_op),
    .zero(),
    .result(alu_result)
    );
  
  always @(posedge clk) begin  
    if (btnu == 1) begin
          accumulator <= 16'b0; // Reset accumulator when `btnu` is pressed
    end else if (btnd == 1) begin
          accumulator <= alu_result[15:0]; // Update accumulator when `btnd` is pressed
    end
  end
  
  assign led = accumulator;
  
endmodule