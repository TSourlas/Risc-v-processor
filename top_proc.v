module top_proc #(parameter INITIAL_PC = 32'h00400000)(
    input clk,
    input rst,
    input [31:0] instr,
    input [31:0] dReadData, 
    output [31:0] PC,
    output [31:0] dAddress,
    output [31:0] dWriteData,
    output reg MemRead,
    output reg MemWrite,
    output [31:0] WriteBackData,
    output reg [3:0] ALUCtrl,
    output reg [2:0] current_state // Define current_state as an output for monitoring
);

    // Signals from datapath
    reg PCSrc, loadPC, RegWrite, ALUSrc, MemtoReg, zero;

    // ALU Control Parameters
    parameter [3:0] 
        ALUOP_AND = 4'b0000,
        ALUOP_OR  = 4'b0001,
        ALUOP_ADD = 4'b0010,
        ALUOP_SUB = 4'b0110,
        ALUOP_SLT = 4'b0100,
        ALUOP_LSR = 4'b1000,
        ALUOP_LSL = 4'b1001,
        ALUOP_ASR = 4'b1010,
        ALUOP_XOR = 4'b0101;

    //OPCODES FROM RISC-V INSTRUCTIONS
    parameter [6:0] 
    OPCODE_LW     = 7'b0000011, // Load instruction
    OPCODE_I_TYPE = 7'b0010011, // Immediate arithmetic
    OPCODE_S_TYPE = 7'b0100011, // Store
    OPCODE_B_TYPE = 7'b1100011; // Branch


    // Instantiate Datapath
    datapath #(.INITIAL_PC(INITIAL_PC)) DATAPATH (
        .clk(clk),
        .instr(instr),
        .PC(PC),
        .dAddress(dAddress),
        .dReadData(dReadData),
        .dWriteData(dWriteData),
        .WriteBackData(WriteBackData),
        .ALUCtrl(ALUCtrl),
        .ALUSrc(ALUSrc),
        .MemtoReg(MemtoReg),
        .RegWrite(RegWrite),
        .PCSrc(PCSrc),
        .loadPC(loadPC)
    );

    // State Definitions using parameter for better readability
    parameter [2:0] 
        IF  = 3'b000,  // Instruction Fetch
        ID  = 3'b001,  // Instruction Decode
        EX  = 3'b010,  // Execute
        MEM = 3'b011,  // Memory Access
        WB  = 3'b100;  // Write Back

    reg [2:0] next_state; // Define next_state as a register

    wire [6:0] opcode = instr[6:0];
    wire [2:0] funct3 = instr[14:12];
    wire [6:0] funct7 = instr[31:25];


    // Aποθήκευση της κατάστασης (ακολουθιακή λογική)
    always @(posedge clk or posedge rst) begin
        if (rst)
            current_state <= IF; // On reset, set current_state to IF
        else
            current_state <= next_state; // On clock edge, move to the next state
    end

    // Λογική Επόμενης Κατάστασης (Συνδυαστική Λογική)
    always @(*) begin
        case (current_state)
            IF: next_state = ID; // Μετάβαση από Instruction Fetch σε Instruction Decode
            ID: next_state = EX; // Μετάβαση από Decode σε Execute (ανεξάρτητα από τον τύπο της εντολής)
            EX: begin
                if (opcode == OPCODE_LW || opcode == 7'OPCODE_S_TYPE) // Load or Store εντολές
                    next_state = MEM;  // Μετάβαση στο Memory Access για Load/Store
                else
                    next_state = WB;   // Άλλες εντολές πάνε απευθείας στο Write Back
            end
            MEM: next_state = WB; // Μετάβαση από Memory Access στο Write Back
            WB: next_state = IF;  // Μετάβαση από Write Back στην Instruction Fetch
            default: next_state = IF; // Κατάσταση προεπιλογής
        endcase
    end

    // Λογική Εξόδων (Συνδυαστική Λογική)
    always @(*) begin
        // Default values for control signals
        MemRead = 0;
        MemWrite = 0;
        RegWrite = 0;
        ALUSrc = 0;
        MemtoReg = 0;
        loadPC = 0;
        PCSrc = 0;


        case (current_state)
            IF: begin
                // Στη φάση IF, διαβάζουμε την εντολή από τη μνήμη
                loadPC = 1; // Ενεργοποίηση σήματος για φόρτωση του PC
            end
            ID: begin
                // Στη φάση ID, γίνεται αποκωδικοποίηση της εντολής
                case (opcode)
                    OPCODE_LW: begin // Load εντολές
                        ALUSrc = 1; // Χρήση immediate
                        MemtoReg = 1;
                        ALUCtrl = ALUOP_ADD; // ADD για υπολογισμό διεύθυνσης
                    end
                    7'OPCODE_S_TYPE: begin // Store εντολές
                        ALUSrc = 1; // Χρήση immediate
                        MemWrite = 1; // Ενεργοποίηση εγγραφής στη μνήμη
                        ALUCtrl = ALUOP_ADD; // ADD για υπολογισμό διεύθυνσης
                    end
                    7'b0110011: begin // R-type εντολές
                        RegWrite = 1; // Ενεργοποίηση εγγραφής σε καταχωρητή
                        case ({funct7, funct3})
                            10'b0000000_000: ALUCtrl = ALUOP_ADD; // ADD
                            10'b0100000_000: ALUCtrl = ALUOP_SUB; // SUB
                            10'b0000000_111: ALUCtrl = ALUOP_AND; // AND
                            10'b0000000_110: ALUCtrl = ALUOP_OR;  // OR
                            10'b0000000_001: ALUCtrl = ALUOP_LSL; // SLL
                            10'b0000000_101: ALUCtrl = ALUOP_LSR; // SRL
                            10'b0000000_010: ALUCtrl = ALUOP_SLT; // SLT
                            10'b0000000_100: ALUCtrl = ALUOP_XOR; // XOR
                            10'b0100000_101: ALUCtrl = ALUOP_ASR; // SRA
                            default: ALUCtrl = ALUOP_AND; // Default or NO OP
                        endcase
                    end
                    7'OPCODE_I_TYPE: begin // I-type εντολές
                        ALUSrc = 1; // Χρήση immediate
                        RegWrite = 1; // Ενεργοποίηση εγγραφής σε καταχωρητή
                        case (funct3)
                            3'b000: ALUCtrl = ALUOP_ADD; // ADDI
                            3'b010: ALUCtrl = ALUOP_SLT; // SLTI
                            3'b100: ALUCtrl = ALUOP_XOR; // XORI
                            3'b110: ALUCtrl = ALUOP_OR;  // ORI
                            3'b111: ALUCtrl = ALUOP_AND; // ANDI
                            3'b001: ALUCtrl = ALUOP_LSL; // SLLI
                            3'b101: begin
                                if (funct7 == 7'b0000000)
                                    ALUCtrl = ALUOP_LSR; // SRLI
                                else if (funct7 == 7'b0100000)
                                    ALUCtrl = ALUOP_ASR; // SRAI
                            end
                            default: ALUCtrl = ALUOP_AND; // Default or NO OP
                        endcase
                    end
                    // Προσθέστε κι άλλες εντολές αν χρειάζεται
                endcase
            end
            EX: begin
                // Στη φάση EX, εκτελούμε την πράξη στην ALU
                if (opcode == 7'OPCODE_B_TYPE) begin // BEQ εντολές (Branch)
                    if (zero) begin
                        PCSrc = 1; // Αν το αποτέλεσμα της ALU είναι 0, κάνουμε branch
                    end
                end
            end
            MEM: begin
                if (opcode == OPCODE_LW) // Load εντολές
                    MemRead = 1; // Ενεργοποίηση ανάγνωσης από τη μνήμη
                 end else if (opcode == OPCODE_S_TYPE) begin
                     MemWrite = 1; // Ενεργοποίηση εγγραφής στη μνήμη για Store
                 end
            WB: begin
                if (opcode == OPCODE_LW) // Load εντολές
                    RegWrite = 1; // Επιστροφή δεδομένων σε καταχωρητή
                    loadPC   = 1;
            end
        endcase
    end

endmodule
