module gearbox66to32 (
    input wire rst,
    input wire clk,
    input wire [65:0] data66,
    
    output logic gearbox_rdy,
    output logic [31:0] data32,
    output logic data_next
);

    logic [7:0] 	  counter;
    logic [31:0]      selected_data_32;
    logic [131:0]     buffer_132;
    logic 	          upper;
    logic             cnt_dly;
    logic [1:0]       delay_cnt;
    
    always_ff @(posedge clk) begin
        if(rst) begin
            counter <= '{default:0};
            gearbox_rdy <= 1'b1;
            cnt_dly <= 1'b0;
            
            delay_cnt <= 2'b00;
        end
        else begin
            if (counter == 7'd65) begin
                counter <= 7'd00;
            end
            else begin
                counter <= counter + 7'd1;
                
                if (counter == 7'd64)
                    gearbox_rdy <= 1'b0;
                else if (counter == 7'd0)
                    gearbox_rdy <= 1'b1;
            end
        end
    end

    always_ff @(posedge clk) begin
        if(rst) 
            buffer_132 <= {data66,data66};
        else if (data_next)
            if (upper)
                buffer_132 <= {data66,buffer_132[65:0]};
            else
                buffer_132 <= {buffer_132[131:66],data66};
    end

   assign data_next = counter[0];
   assign upper = ~counter[1];

   function logic [31:0] slice( logic [131:0] vector, logic [6:0] seg);
      logic [131:0] vector_rot;
      vector_rot = (vector >> ((seg*32)%132)) | (vector << (132-(seg*32)%132));
      return vector_rot[31:0];
   endfunction // slice

   always_comb begin
      selected_data_32 = 'z;
      for (int i = 0; i<67; i++)
	if (counter == i)
	  selected_data_32 = slice(buffer_132,i);
   end

   always_ff @(posedge clk) begin
      //if (gearbox_rdy)
        data32 <= selected_data_32;
   
   end
endmodule