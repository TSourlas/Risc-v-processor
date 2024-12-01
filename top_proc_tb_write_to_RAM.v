module top_proc_tb;

    reg clk;
    reg rst;
    wire [31:0] instr;
    reg [31:0] dReadData;
    wire [31:0] PC;
    wire [31:0] dAddress;
    wire [31:0] dWriteData;
    wire [31:0] WriteBackData;
    wire MemRead;
    wire MemWrite;
    reg we;
    reg [8:0] addr;
    reg [31:0] din;
    wire [31:0] dout;
    wire [31:0] instruction;
    wire [3:0] ALUCtrl;

    // Instantiate the top_proc module
    top_proc uut (
        .clk(clk),
        .rst(rst),
        .instr(instr),
        .dReadData(dReadData),
        .PC(PC),
        .MemWrite(MemWrite),
        .dAddress(dAddress),
        .dWriteData(dWriteData),
        .WriteBackData(WriteBackData),
        .ALUCtrl(ALUCtrl)
    );

    // Instantiate the ROM (Instruction Memory)
    INSTRUCTION_MEMORY imem (
        .clk(clk),
        .addr(addr),
        .dout(instruction)
    );

    // Instantiate the RAM (Data Memory)
    DATA_MEMORY dmem (
        .clk(clk),
        .we(MemWrite),
        .addr(addr),
        .din(dWriteData),
        .dout(dout)
    );

    initial begin
        // Initialize signals
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        // Reset the design
        #5 rst = 0;
        #5 rst = 1;
    end

    assign instr = instruction;

   initial begin
        // Wait for initial clock edge
        #10;

        // Loop through a range of addresses
        for (addr = 0; addr < 80; addr = addr + 4) begin
            #10; // Wait for one clock cycle
            $display("Address: %0d, PC: %d Instruction: %b", addr, PC, instr);
            $display("Test ADD Result (x3 = x1 + x2): %b", WriteBackData);
            if (MemWrite) begin
                $display("Writing to RAM %h", dWriteData);
            end
            #10;
            display_registers();
        end

        // End simulation
        $finish;
    end

    task display_registers;
          integer i;
          begin
              $display("Register File Contents:");
              for (i = 0; i < 80; i = i + 4) begin
                // Assuming you have a way to access the internal register contents
                // You may need to modify the regfile module to expose the registers for testing
                $display("x%d = %h", i, dmem.RAM[i]/*uut.DATAPATH.rf.registers[i]*/); // Adjust based on your regfile implementation
              end
          end
    endtask

endmodule
