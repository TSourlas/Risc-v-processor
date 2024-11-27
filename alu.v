module alu(
  input [31:0] op1,
  input [31:0] op2,
  input [3:0] alu_op,
  output zero,
  output [31:0] result
  );
 
  parameter[3:0] ALUOP_AND = 4'b0000;
  parameter[3:0] ALUOP_OR  = 4'b0001;
  parameter[3:0] ALUOP_ADD = 4'b0010;
  parameter[3:0] ALUOP_SUB = 4'b0110;
  parameter[3:0] ALUOP_SLT = 4'b0100;
  parameter[3:0] ALUOP_LSR = 4'b1000;
  parameter[3:0] ALUOP_LSL = 4'b1001;
  parameter[3:0] ALUOP_ASR = 4'b1010;
  parameter[3:0] ALUOP_XOR = 4'b0101;
  
  reg [31:0] res;

  always @(*) begin
    case (alu_op)
            ALUOP_AND: res = op1 & op2;
            ALUOP_OR: res = op1 | op2;
            ALUOP_ADD: res = op1 + op2;
            ALUOP_SUB: res = op1 - op2;
      		ALUOP_SLT: res = ($signed(op1) < $signed(op2)) ? 32'd1 : 32'd0;
      	    ALUOP_LSR: res = op1 >> op2[4:0];
            ALUOP_LSL: res = op1 << op2[4:0];
      		ALUOP_ASR: res = ($signed(op1)) >>> op2[4:0];
      		ALUOP_XOR: res = op1 ^ op2;
            default: res = 32'd0;
        endcase
    end

	assign result = res;

  assign zero = (res == 32'd0) ? 1'b1 : 1'b0;

endmodule
  
 