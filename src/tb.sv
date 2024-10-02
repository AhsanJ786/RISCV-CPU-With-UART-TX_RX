
module tb();
    
    reg clk=1'b1,rst,e_inter,t_inter=1'b0;

    Single_Cycle_Top  single_cycle_top(
                                 .clk(clk),
                                 .rst(rst),
                                 .e_inter(e_inter),
                                 .t_inter(t_inter)
    );

    initial begin
        $dumpfile("Single Cycle.vcd");
        $dumpvars(0);
    end

    always 
    begin
        clk = ~ clk;
        #100;  
        
    end
    
    initial
    begin
        rst <= 1'b0;
        #100;

        
        rst <=1'b1;
       // #1400 t_inter <= 1'b1;
       // #200 t_inter <= 1'b0;
        #240000;
        $finish;
    end
endmodule