`default_nettype none

module vga_timing (
    input wire clk,
    input wire rst_n,
    output reg [5:0] x_hi,
    output reg [4:0] x_lo,
    output reg [4:0] y_hi,
    output reg [5:0] y_lo,
    output reg hsync,
    output reg vsync,
    output wire blank
);

// 640x480 60Hz CVT (25.175 MHz pixel clock, rounded to 25 MHz)

`define H_ROLL   19
`define H_FPORCH (32 * 32)
`define H_SYNC   (32 * 32 + 16)
`define H_BPORCH (37 * 32 + 12)
`define H_NEXT   (39 * 32 + 19)

`define V_ROLL   29
`define V_FPORCH (16 * 64)
`define V_SYNC   (16 * 64 + 10)
`define V_BPORCH (16 * 64 + 12)
`define V_NEXT   (17 * 64 + 14)

always @(posedge clk) begin
    if (!rst_n) begin
        x_hi <= 0;
        x_lo <= 0;
        y_hi <= 0;
        y_lo <= 0;
        hsync <= 0;
        vsync <= 0;
    end else begin
        if ({x_hi, x_lo} == `H_NEXT) begin
            x_hi <= 0;
            x_lo <= 0;
        end else if (x_lo == `H_ROLL) begin
            x_hi <= x_hi + 1;
            x_lo <= 0;
        end else begin
            x_lo <= x_lo + 1;
        end
        if ({x_hi, x_lo} == `H_SYNC) begin
            if({y_hi, y_lo} == `V_NEXT) begin
                y_hi <= 0;
                y_lo <= 0;
            end else if (y_lo == `V_ROLL) begin
                y_hi <= y_hi + 1;
                y_lo <= 0;
            end else begin
                y_lo <= y_lo + 1;
            end
        end
        hsync <= !({x_hi, x_lo} >= `H_SYNC && {x_hi, x_lo} < `H_BPORCH);
        vsync <= ({y_hi, y_lo} >= `V_SYNC && {y_hi, y_lo} < `V_BPORCH);
    end
end

assign blank = ({x_hi, x_lo} >= `H_FPORCH || {y_hi, y_lo} >= `V_FPORCH);

endmodule
