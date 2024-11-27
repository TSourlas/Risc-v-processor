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
    wire [2:0] current_state;  // Monitor FSM state of uut

    // Instantiate the top_proc module
    top_proc uut (
        .clk(clk),
        .rst(rst),
        .instr(instr),
        .dReadData(dReadData),
        .PC(PC),
        .dAddress(dAddress),
        .dWriteData(dWriteData),
        .WriteBackData(WriteBackData),
        .ALUCtrl(ALUCtrl),
        .current_state(current_state) // Connect FSM state output
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
        .we(we),
        .addr(addr),
        .din(din),
        .dout(dout)
    );

    // Clock signal generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10 ns clock period
    end

    // Reset sequence
    initial begin
        rst = 1;
        #10;
        rst = 0;
    end

    assign instr = instruction;

    integer cycle_count;
    integer instruction_count = 0;
    integer max_instructions = 10;  // Set a limit for the number of instructions to execute

    initial begin
        // Wait for initial clock edge
        #20;

        // Initialize cycle counter
        cycle_count = 0;

        // Loop to track and execute instructions with a limit
        while (instruction_count < max_instructions) begin
            @(posedge clk);
            cycle_count = cycle_count + 1;

            // Check if current_state indicates the start of a new instruction (IF state)
            if (current_state == 3'b000) begin  // Assuming 3'b000 is the IF state
                if (cycle_count > 1) begin  // If not the initial reset phase
                    $display("Instruction completed in %0d clock cycles", cycle_count);
                    cycle_count = 0; // Reset cycle count for the next instruction
                    instruction_count = instruction_count + 1;
                end
            end

            // Display memory reads if MemRead is active
            if (MemRead) begin
                $display("Reading from RAM: addr = %h, data = %h", dAddress, dReadData);
            end

            // Display memory writes if MemWrite is active
            if (MemWrite) begin
                $display("Writing to RAM: addr = %h, data = %h", dAddress, dWriteData);
            end
        end

        // End simulation after executing the defined number of instructions
        $display("Testbench completed: Executed %0d instructions", instruction_count);
        $finish;
    end

    // Display register contents after each instruction
    task display_registers;
        integer i;
        begin
            $display("Register File Contents:");
            for (i = 0; i < 32; i = i + 1) begin
                // Assuming you have a way to access the internal register contents
                // Modify the regfile module to expose the registers for testing if needed
                $display("x%d = %h", i, uut.DATAPATH.rf.registers[i]); // Adjust based on your regfile implementation
            end
        end
    endtask

endmodule
