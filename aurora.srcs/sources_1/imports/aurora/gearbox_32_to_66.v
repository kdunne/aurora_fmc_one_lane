// This module is based off a design used in the RD53A tapeout.

module gearbox32to66 (
    input rst,
    input clk,
    input [31:0] data32,
    input gearbox_slip,
    
    output reg gearbox_rdy,
    output reg [65:0] data66,
    output reg data_valid
);

reg         cycle;
reg [7:0]   counter;
reg         first_cycle;    

reg [1:0]   buffer_pos;
reg [127:0] buffer_128;
reg [127:0] rotate;

reg [127:0] left_shift;
reg [127:0] right_shift;

wire data_valid_i;

always @(posedge clk) begin
    if (rst) begin
        gearbox_rdy <= 1'b0;
        counter <= 8'd75;
        first_cycle <= 1'b1;       
    end
    else if (gearbox_slip) begin
        counter <= counter;
    end
    else begin
        if ((counter == 8'd65) && (first_cycle == 1)) begin
            first_cycle <= 1'b0;
            counter <= 8'd64;
            gearbox_rdy <= 1'b0;
        end
        else if (counter == 8'd129) begin
            counter <= 8'd0;
            first_cycle <= 1'b1;
            gearbox_rdy <= 1'b0;
        end
        else begin
            counter <= counter + 1;
            if ((counter == 8'd65) && (first_cycle == 0)) begin
                gearbox_rdy <= 1'b1;
            end
            else if (counter == 8'd1) begin
                gearbox_rdy <= 1'b1;
            end
        end
    end
end

always @(posedge clk) begin
    if (rst) begin
        buffer_pos <= 2'd1;
    end
    else begin
        buffer_pos <= buffer_pos + 1;
    end
end

assign data_valid_i = counter[0];

always @(posedge clk) begin
    if (rst) begin
        buffer_128 <= {4{data32}};
    end
    else begin
        case (buffer_pos)
            2'b00: buffer_128 <= {buffer_128[127:32], data32};
            2'b01: buffer_128 <= {buffer_128[127:64], data32, buffer_128[31:0]};
            2'b10: buffer_128 <= {buffer_128[127:96], data32, buffer_128[63:0]};
            2'b11: buffer_128 <= {data32, buffer_128[95:0]};
        endcase
    end
end
    
// Rotate so the output bits are in the least significant position
always @(*) begin
    left_shift = buffer_128 << ((counter[7:1]*66)%128);
    right_shift = buffer_128 >> ((counter[7:1]*66)%128);
    rotate = (buffer_128 >> ((counter[7:1]*66)%128)) | (buffer_128 << (128 - (counter[7:1]*66)%128));
end

always @(posedge clk) begin
    if (rst) begin
        data66 <= 66'b0;
        data_valid <= 1'b0;
    end
    else begin
        if (data_valid_i) begin
            data66 <= rotate[65:0];
        end
            data_valid <= data_valid_i;
    end
end
    
endmodule