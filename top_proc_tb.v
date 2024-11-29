module top_proc_tb;

    // Declare input signals for top_proc
    reg clk;
    reg rst;
    reg [31:0] dReadData;  // Data for reading from memory
    wire [31:0] PC, dAddress, dWriteData, WriteBackData;
    wire MemRead, MemWrite, RegWrite, ALUSrc, MemtoReg;
    wire [3:0] ALUCtrl;
    wire [2:0] current_state;
    wire [31:0] instr;  // Instruction from ROM (driven by ROM)

    // Instantiate the top_proc module (DUT)
    top_proc uut (
        .clk(clk),
        .rst(rst),
        .instr(instr),  // Instruction will come from ROM
        .dReadData(dReadData),
        .PC(PC),
        .dAddress(dAddress),
        .dWriteData(dWriteData),
        .WriteBackData(WriteBackData),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .ALUCtrl(ALUCtrl),
        .current_state(current_state)
    );

    // Clock generation (toggle every 5 time units)
    always #5 clk = ~clk;

    // Initial stimulus block
    initial begin
        // Initialize signals
        clk = 0;
        rst = 0;
        dReadData = 32'b0;
        
        // Enable waveform dumping to a file
        $dumpfile("testbench.vcd");  // Specifies the VCD file name
        $dumpvars(0, top_proc_tb);   // Dumps all signals at the top level of the testbench

        // End simulation after a few cycles
        #1160;
        $finish;
    end

endmodule
