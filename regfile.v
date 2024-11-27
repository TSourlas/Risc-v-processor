module regfile #(parameter DATAWIDTH = 32)(
  input clk,
  input [4:0] readReg1,
  input [4:0] readReg2,
  input [4:0] writeReg,
  input [DATAWIDTH-1:0] writeData,
  input write,
  output reg [DATAWIDTH-1:0] readData1,
  output reg [DATAWIDTH-1:0] readData2
  );
  // Define a 32xDATAWIDTH register file
  reg [DATAWIDTH-1:0] registers [31:0]; // 32 registers, each DATAWIDTH bits wide
  
  integer i;
  
  // Initialize the registers to 0
  initial begin
    for(i = 0; i < 32; i = i + 1)
      registers[i] <= {DATAWIDTH{1'b0}};  // Initialize each register to 0
  end
  
  // Sequential block for reading and writing registers
  always @(*) begin
    // Read data from the register file
    readData1 <= registers[readReg1];
    readData2 <= registers[readReg2];
    
    // Write data to the register file
    if (write)
      registers[writeReg] <= writeData;
  end
endmodule
