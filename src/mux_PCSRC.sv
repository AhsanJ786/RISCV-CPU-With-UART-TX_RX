module mux_PCSRC(a,b,s,c);
   input wire [31:0] a,b;
   input wire  s;
   output reg [31:0] c;

   always@(*)
   case (s)
          1: c = b; 
    default: c = a;
   endcase
    
endmodule