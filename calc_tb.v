module calc_tb();
  
  // Declare registers and wires for the testbench
  reg clk;
  reg btnc, btnl, btnu, btnr, btnd;
  reg [15:0] sw;
  wire [15:0] led;
  
  // Instantiate the calc DUT
  calc CALC(
    .clk(clk),
    .btnc(btnc),
    .btnl(btnl),
    .btnu(btnu),
    .btnr(btnr),
    .btnd(btnd),
    .sw(sw),
    .led(led)
  );
  
  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk;  // Toggle clock every 5 time units (10 ns period)
  end
  
    // Dump waveforms for simulation
  initial begin
    $dumpfile("dump.vcd"); // Specify the dump file name
    $dumpvars;             // Dump all variables to the file
  end

  
  // Test sequence
  initial begin
    // Initialize inputs
    btnc = 0;
    btnl = 0;
    btnu = 0;
    btnr = 0;
    btnd = 0;
    sw = 16'h0000;
    
    // Reset the accumulator
    #10 btnu = 1;  // Press reset button
    #10 btnu = 0;  // Release reset button
    #10; // Wait a bit
    
    // Apply Test Cases
    // Test case 1: ADD operation (0,1,0) - 0x0 + 0x354a -> Expected 0x354a
    btnl = 0;
    btnc = 1;
    btnr = 0;
    sw = 16'h354a;  // Input switches
    btnd = 1;  // Apply ALU operation
    #10 btnd = 0; // Release the button
    #10; // Wait to apply next operation
    $display("ADD: Expected: 0x354a, Got: %h", led);
    
    // Test case 2: SUB operation (0,1,1) - 0x354a - 0x1234 -> Expected 0x2316
    btnl = 0;
    btnc = 1;
    btnr = 1;
    sw = 16'h1234;  // Input switches
    btnd = 1;  // Apply ALU operation
    #10 btnd = 0; // Release the button
    #10; // Wait to apply next operation
    $display("SUB: Expected: 0x2316, Got: %h", led);

    // Test case 3: OR operation (0,0,1) - 0x2316 | 0x1001 -> Expected 0x3317
    btnl = 0; 
    btnc = 0; 
    btnr = 1;
    sw = 16'h1001;  // Input switches
    btnd = 1;  // Apply ALU operation
    #10 btnd = 0;
    #10;
    $display("OR: Expected: 0x3317, Got: %h", led);

    // Test case 4: AND operation (0,0,0) - 0x3317 & 0xf0f0 -> Expected 0x3010
    btnl = 0; 
    btnc = 0; 
    btnr = 0;
    sw = 16'hf0f0;  // Input switches
    btnd = 1;  // Apply ALU operation
    #10 btnd = 0;
    #10;
    $display("AND: Expected: 0x3010, Got: %h", led);

    // Test case 5: XOR operation (1,1,1) - 0x3010 ^ 0x1fa2 -> Expected 0x2fb2
    btnl = 1; 
    btnc = 1; 
    btnr = 1;
    sw = 16'h1fa2;  // Input switches
    btnd = 1;  // Apply ALU operation
    #10 btnd = 0;
    #10;
    $display("XOR: Expected: 0x2fb2, Got: %h", led);

    // Test case 6: ADD operation (0,1,0) - 0x2fb2 + 0x6aa2 -> Expected 0x9a54
    btnl = 0; 
    btnc = 1; 
    btnr = 0;
    sw = 16'h6aa2;  // Input switches
    btnd = 1;  // Apply ALU operation
    #10 btnd = 0;
    #10;
    $display("ADD: Expected: 0x9a54, Got: %h", led);

    // Test case 7: Logical Shift Left (1,0,1) - 0x9a54 << 1 -> Expected 0xa540
    btnl = 1; 
    btnc = 0; 
    btnr = 1;
    sw = 16'h0004;  // Input switches (Shift value)
    btnd = 1;  // Apply ALU operation
    #10 btnd = 0;
    #10;
    $display("Logical Shift Left: Expected: 0xa540, Got: %h", led);

    // Test case 8: Shift Right Arithmetic (1,1,0) - 0xa540 >> 1 -> Expected 0xd2a0
    btnl = 1; 
    btnc = 1; 
    btnr = 0;
    sw = 16'h0001;  // Input switches (Shift value)
    btnd = 1;  // Apply ALU operation
    #10 btnd = 0;
    #10;
    $display("Shift Right Arithmetic: Expected: 0xd2a0, Got: %h", led);

    // Test case 9: Less Than (1,0,0) - (0xd2a0 < 0x46ff) -> Expected 0x0001
    btnl = 1; 
    btnc = 0; 
    btnr = 0;
    sw = 16'h46ff;  // Input switches
    btnd = 1;  // Apply ALU operation
    #10 btnd = 0;
    #10;
    $display("Less Than: Expected: 0x0001, Got: %h", led);		
    
    // Finish simulation after a while
    #100;
    $finish;
  end
endmodule
