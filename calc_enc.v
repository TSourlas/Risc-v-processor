module calc_enc(
  input btnl,
  input btnc,
  input btnr,
  output wire [3:0] alu_op
  );
  
  wire not_btnc,not_btnl,not_btnr;
  wire and1_out,and2_out,and3_out,and4_out,
  and5_out,and6_out,and7_out,
  and8_out,and9_out,and10_out,and11_out;

  //alu_op[0]
  not(not_btnc,btnc);

  and(and1_out,not_btnc,btnr);
  and(and2_out,btnl,btnr);

  or(alu_op[0],and1_out,and2_out);

  //alu_op[1]
  not(not_btnl,btnl);
  not(not_btnr,btnr);

  and(and3_out,not_btnl,btnc);
  and(and4_out,btnc,not_btnr);
  	
  or(alu_op[1],and3_out,and4_out);
  
  //alu_op[2]
  and(and5_out,btnl,not_btnc);
  and(and6_out,btnc,btnr);
  and(and7_out,and5_out,not_btnr);
  
  or(alu_op[2],and6_out,and7_out);

  //alu_op[3]
  and(and8_out,btnl,not_btnc);
  and(and9_out,btnl,btnc);
  and(and10_out,and8_out,btnr);
  and(and11_out,and9_out,not_btnr);

  or(alu_op[3],and10_out,and11_out); 
endmodule