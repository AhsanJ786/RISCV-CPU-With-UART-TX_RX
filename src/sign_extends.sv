module sign_ext(In,Imm_ext,ImmSrc);

input [31:0] In;
output [31:0] Imm_ext;
input [2:0]ImmSrc;



assign Imm_ext = (ImmSrc == 3'b000) ? {{20{In[31]}}, In[31:20]} :                      
                 (ImmSrc == 3'b001) ? {{20{In[31]}}, In[31:25], In[11:7]} :
                 (ImmSrc == 3'b010) ? {{20{In[31]}}, In[7], In[30:25], In[11:8],1'b0}: 
                 (ImmSrc == 3'b011) ?{{12{In[31]}}, In[19:12], In[20], In[30:21],1'b0}:
                 (ImmSrc == 3'b100) ? {In[31:12], 12'b000000000000}: 32'h00000000;

endmodule