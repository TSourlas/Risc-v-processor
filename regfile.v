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
  always @(posedge clk) begin
    // Write to the register if 'write' is asserted
    if (write) begin
        registers[writeReg] = writeData;
    end
    
    // Priority given to the write operation if it's the same register
    if (readReg1 == writeReg) begin
        readData1 = writeData;  // Read the written data if the register is the same
    end else begin
        readData1 = registers[readReg1];  // Otherwise, read from the register
    end
    
    if (readReg2 == writeReg) begin
        readData2 = writeData;  // Read the written data if the register is the same
    end else begin
        readData2 = registers[readReg2];  // Otherwise, read from the register
    end
  end
endmodule
