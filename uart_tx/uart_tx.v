module uart_tx(
    input clk_3125,
    input parity_type, 
    input tx_start,
    input [7:0] data,
    output reg tx, 
    output reg tx_done
);

//////////////////DO NOT MAKE ANY CHANGES ABOVE THIS LINE//////////////////

parameter IDLE = 1'b1;  
parameter START_BIT = 1'b0; 
parameter STOP_BIT = 1'b1;  
parameter DATA_BITS = 8;    
parameter CLK_CYCLES_PER_BIT = 13; 

reg [3:0] bit_count = 0;  // To track bit (0-10: start, 8 data, parity, stop) 
reg [3:0] clk_count = 0;  // To count clock cycles for each bit
reg parity_bit;           // Parity bit to be calculated
reg transmitting;         // Flag to indicate transmission in progress
reg [7:0] data_reg;       // Register to store data during transmission

initial begin
    tx = IDLE;        
    tx_done = 0;      
    transmitting = 0; 
end

always @(posedge clk_3125) begin
    tx_done <= 0;  // Default: clear tx_done
    
    if (!transmitting && tx_start) begin
        // Start transmission
        tx <= START_BIT;        
        transmitting <= 1;
        bit_count <= 0;         
        clk_count <= 0;
        data_reg <= data;  // Store input data
        parity_bit <= parity_type ? ~^data : ^data; // Compute parity bit
    end
    else if (transmitting) begin
        if (clk_count < CLK_CYCLES_PER_BIT - 1) begin
            // Still counting clock cycles for current bit
            clk_count <= clk_count + 1;
        end
        else begin
            // Completed clock cycles for current bit, move to next bit
            clk_count <= 0;
            bit_count <= bit_count + 1;
            
            case (bit_count + 1)  // Next bit to transmit
                4'd0: tx <= data_reg[0];  // LSB first
                4'd1: tx <= data_reg[1]; 
                4'd2: tx <= data_reg[2]; 
                4'd3: tx <= data_reg[3]; 
                4'd4: tx <= data_reg[4]; 
                4'd5: tx <= data_reg[5]; 
                4'd6: tx <= data_reg[6]; 
                4'd7: tx <= data_reg[7];  // MSB last
                4'd8: tx <= parity_bit;   // Parity bit
                4'd9: tx <= STOP_BIT;     // Stop bit
                4'd10: begin
                    tx <= IDLE;           // Return to idle
                    transmitting <= 0;    // Transmission complete
                    tx_done <= 1;         // Signal completion
                end
                default: begin
                    tx <= IDLE;
                    transmitting <= 0;
                end
            endcase
        end
    end
    else begin
        // Not transmitting and no start signal
        tx <= IDLE;
    end
end

//////////////////DO NOT MAKE ANY CHANGES BELOW THIS LINE//////////////////
endmodule
