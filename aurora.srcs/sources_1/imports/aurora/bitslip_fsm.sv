// Bitslip FSM
// Author: Lev Kurilenko
// Date: 7/19/2017

// Description:
// This module takes rxgearboxslip and blocksync from
// the block_sync.v module and decides whether to bitslip
// the iserdes or the rx gearbox. For every 8 iserdes 
// bitslip assertions there is a single rx gearbox bitslip
// assertion. This continues until either blocksync goes
// high, meaning the lane is synced, or all combinations
// have been exhausted.

module bitslip_fsm (
    input logic clk,
    input logic rst,
    
    input logic blocksync,
    input logic rxgearboxslip,
    
    output logic iserdes_slip,
    output logic gearbox_slip
);


logic [3:0] iserdes_slip_cnt;    // 8 different values
logic [7:0] gearbox_slip_cnt;   // 64 different values, might need to be 32 different values
logic [1:0] slip_delay_cnt;

logic [3:0] iserdes_slip_cnt_next;
logic [7:0] gearbox_slip_cnt_next;
logic [1:0] slip_delay_cnt_next;

typedef enum {IDLE, ISERDES_SLIP, BOTH_SLIP, SYNC_FINISHED, EXHAUSTED_COMB} state;
state bitslip_state;
state bitslip_state_next;

always_ff @(posedge clk) begin
    if (rst) begin
        iserdes_slip_cnt    <= 4'h0;
        gearbox_slip_cnt    <= 8'h00;
        slip_delay_cnt      <= 2'h0;
        bitslip_state       <= IDLE;
    end
    else begin
        iserdes_slip_cnt    <= iserdes_slip_cnt_next;
        gearbox_slip_cnt    <= gearbox_slip_cnt_next;
        slip_delay_cnt      <= slip_delay_cnt_next;
        bitslip_state       <= bitslip_state_next;
    end
end

always_comb begin
    iserdes_slip_cnt_next   = iserdes_slip_cnt;
    gearbox_slip_cnt_next   = gearbox_slip_cnt;
    slip_delay_cnt_next     = slip_delay_cnt;
    bitslip_state_next      = bitslip_state;
    iserdes_slip = 0;
    gearbox_slip = 0;

    case (bitslip_state)
        IDLE: begin
            if (blocksync) begin
                bitslip_state_next   <= SYNC_FINISHED;
                iserdes_slip_cnt_next   = 4'h0;
                gearbox_slip_cnt_next   = 8'h00;
                iserdes_slip = 0;
                gearbox_slip = 0;
            end
            else if ((gearbox_slip_cnt == 129) && (iserdes_slip_cnt == 7)) begin
                //bitslip_state_next   <= EXHAUSTED_COMB;
                
                // TEMP TEST CODE
                bitslip_state_next   <= IDLE;
                iserdes_slip_cnt_next   = 4'h0;
                gearbox_slip_cnt_next   = 8'h00;
                
                iserdes_slip = 0;
                gearbox_slip = 0;
            end
            else if (rxgearboxslip) begin
                if (iserdes_slip_cnt == 7) begin
                    bitslip_state_next      <= BOTH_SLIP;
                    gearbox_slip_cnt_next   = gearbox_slip_cnt + 1;
                    slip_delay_cnt_next     <= slip_delay_cnt + 1;
                    iserdes_slip_cnt_next   = 4'h0;
                    iserdes_slip            = 1;
                    gearbox_slip            = 1;
                end
                else begin
                    bitslip_state_next   <= ISERDES_SLIP;
                    iserdes_slip_cnt_next   = iserdes_slip_cnt + 1;
                    slip_delay_cnt_next     <= slip_delay_cnt + 1;
                    iserdes_slip = 1;
                    gearbox_slip = 0;
                end
            end
        end
        ISERDES_SLIP: begin
            iserdes_slip = 0;
            slip_delay_cnt_next     <= slip_delay_cnt + 1;
            if (slip_delay_cnt == 3) begin
                bitslip_state_next   <= IDLE;
            end
        end
        BOTH_SLIP: begin         // Hold gearboxslip high for 4 160MHz clock cycles (1 40MHz clock cycle)
            iserdes_slip = 0;
            gearbox_slip = 1;
            slip_delay_cnt_next     <= slip_delay_cnt + 1;
            if (slip_delay_cnt == 3) begin
                bitslip_state_next   <= IDLE;
            end
        end
        SYNC_FINISHED: begin
            if (blocksync) begin
                bitslip_state_next   <= SYNC_FINISHED;
            end
            else begin
                bitslip_state_next   <= IDLE;
            end
        end
        EXHAUSTED_COMB: begin
            bitslip_state_next   <= EXHAUSTED_COMB;
        end
        default: begin
            iserdes_slip_cnt_next   = 4'h0;
            gearbox_slip_cnt_next   = 8'h00;
            
            iserdes_slip = 1;
            gearbox_slip = 0;
            
            bitslip_state_next   <= IDLE;
        end
    endcase
end

endmodule