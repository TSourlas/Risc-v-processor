module datapath #(parameter INITIAL_PC = 32'h00400000, parameter DATAWIDTH = 32)(
    input clk,
    input rst,
    input [31:0] instr,
    input PCSrc,
    input ALUSrc,
    input RegWrite,
    input MemtoReg,
    input [3:0] ALUCtrl,
    input loadPC,
    output reg [31:0] PC,
    output zero,
    output wire [31:0] dAddress,
    output [31:0] dWriteData,
    input [31:0] dReadData,
    output [31:0] WriteBackData
);

        wire [4:0] readReg1, readReg2, writeReg; // 5-bit wires to hold the addresses of registers to be read (`readReg1` and `readReg2`) and written (`writeReg`)
        wire [31:0] branch_offset;  // 32-bit wire to hold the branch offset value
        reg [31:0] next_PC;          
        wire [31:0] selected_imm;  // 32-bit wire to hold the selected immediate value (`imm_I`, `imm_B`, or `imm_S`)
        wire [31:0] readData1, readData2;  // 32-bit wires to hold the data read from the two source registers (`readData1` and `readData2`)
        wire [31:0] imm_I, imm_B, imm_S;  // 32-bit wires to hold different types of immediate values decoded from the instruction
        wire [31:0] op2;

        // Register File Instantiation
        regfile #(.DATAWIDTH(DATAWIDTH)) rf (
            .clk(clk),
            .readReg1(readReg1),
            .readReg2(readReg2),
            .writeReg(writeReg),
            .writeData(WriteBackData), 
            .write(RegWrite),
            .readData1(readData1),
            .readData2(readData2)
        );

        // ALU Instantiation
        alu ALU(
            .op1(readData1),
            .op2(op2),
            .alu_op(ALUCtrl),
            .result(dAddress),
            .zero(zero) 
        );

        // Define type of instruction
        localparam OPCODE_LW     = 7'b0000011; // Load instruction
        localparam OPCODE_I_TYPE = 7'b0010011; // Immediate arithmetic
        localparam OPCODE_S_TYPE = 7'b0100011; // Store
        localparam OPCODE_B_TYPE = 7'b1100011; // Branch
    
        wire [6:0] opcode = instr[6:0]; // Extract opcode
        
        initial begin
            PC = INITIAL_PC;
        end

        // Extract immediate type
        assign imm_I = {{20{instr[31]}}, instr[31:20]};  // I-type immediate
        assign imm_S = {{20{instr[31]}}, instr[31:25], instr[11:7]};  // S-type immediate
        assign imm_B = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0}; // B-type immediate

        // Decode register addresses from instruction
        assign readReg1 = instr[19:15]; // rs1
        assign readReg2 = instr[24:20]; // rs2
        assign writeReg = instr[11:7];  // rd

        // Choose the type of immediate based on opcode
        assign selected_imm = (opcode == OPCODE_LW) ? imm_I :
                            (opcode == OPCODE_I_TYPE) ? imm_I :
                            (opcode == OPCODE_S_TYPE) ? imm_S :
                            (opcode == OPCODE_B_TYPE) ? imm_B:
                            imm_I;

        assign branch_offset = imm_B + 32'd4;
        assign op2 = (ALUSrc) ? selected_imm : readData2; // ALU second operand  
        assign dWriteData = (MemtoReg) ? dReadData : dAddress; 
        assign WriteBackData = dWriteData;

        always @(posedge clk or posedge rst) begin
            if (loadPC) begin
                PC = (PCSrc) ? (PC + branch_offset) : (PC + 32'd4); // Update PC
            end else if (rst) begin
                PC = INITIAL_PC;    // Set PC to initial value
            end
        end 
endmodule
