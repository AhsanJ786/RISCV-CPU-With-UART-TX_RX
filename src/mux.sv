module mux(a,b,c,s);
   input wire [31:0] a,b;
   input wire  s;
   output wire [31:0] c;

assign c = ( ~s)? a:b;
    
endmodule