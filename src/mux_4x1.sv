module mux_8x1(a,b,c,d,e,s,out);
   input wire [31:0] a,b,c,d,e;
   input wire [2:0] s;
   output wire [31:0] out;

   assign out = (s == 3'b000) ? a:
                (s == 3'b001) ? b:
                (s == 3'b010) ? c:
                (s == 3'b011) ? d:
                (s == 3'b100) ? e:3'b000;

endmodule