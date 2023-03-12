`timescale 1ns/1ps
`define clk_period 20
module axi_stream_insert_header_tb
#(
parameter DATA_WD = 32,
parameter DATA_BYTE_WD = DATA_WD / 8,
parameter BYTE_CNT_WD = $clog2(DATA_BYTE_WD));

reg clk;
reg rst_n;

reg valid_in;
reg [DATA_WD-1 : 0] data_in;
reg [DATA_BYTE_WD-1 : 0] keep_in;
reg last_in;
wire ready_in;

wire valid_out;
wire [DATA_WD-1 : 0] data_out;
wire [DATA_BYTE_WD-1 : 0] keep_out;
wire last_out;
reg ready_out;

reg valid_insert;
reg [DATA_WD-1 : 0] data_insert;
reg [DATA_BYTE_WD-1 : 0] keep_insert;
reg [BYTE_CNT_WD-1 : 0] byte_insert_cnt;
wire ready_insert;

axi_stream_insert_header axi_stream_insert_header_u(
.clk(clk),
.rst_n(rst_n),
// AXI Stream input original data
.valid_in(valid_in),
.data_in(data_in),
.keep_in(keep_in),
.last_in(last_in),
.ready_in(ready_in),
// AXI Stream output with header inserted
.valid_out(valid_out),
.data_out(data_out),
.keep_out(keep_out),
.last_out(last_out),
.ready_out(ready_out),
// The header to be inserted to AXI Stream input
.valid_insert(valid_insert),
.data_insert(data_insert),
.keep_insert(keep_insert),
.byte_insert_cnt(byte_insert_cnt),
.ready_insert(ready_insert)
);

always #(`clk_period/2)   clk = ~clk;
initial begin
clk = 1;
rst_n = 0;

// The header to be inserted to AXI Stream input
valid_insert = 0;
data_insert = 0;
keep_insert = 0;
byte_insert_cnt = 0;
// AXI Stream input original data
valid_in = 0;
data_in = 0;
keep_in = 0;
last_in = 0;
// AXI Stream output with header inserted
ready_out = 0;

#(`clk_period*3);
rst_n = 1;

repeat(100)begin

// The header to be inserted to AXI Stream input
valid_insert = $urandom;
data_insert = $urandom;
byte_insert_cnt = $urandom($random);
keep_insert = 4'b1111 >> 3 - byte_insert_cnt;
// AXI Stream input original data
valid_in = $urandom;
data_in = $urandom;
keep_in = 4'b1111;
last_in = 1'b0;
// AXI Stream output with header inserted
ready_out = $urandom;

#(`clk_period*1);
end

// The header to be inserted to AXI Stream input
valid_insert = $urandom;
data_insert = $urandom;
byte_insert_cnt = $urandom;
keep_insert = 4'b1111 >> 3 - byte_insert_cnt;
// AXI Stream input original data
valid_in = 0;
data_in = $urandom;
keep_in = 4'b1111 << $urandom;
last_in = 1'b1;
// AXI Stream output with header inserted
ready_out = 0;

#(`clk_period*1);

// The header to be inserted to AXI Stream input
valid_insert = $urandom;
data_insert = $urandom;
byte_insert_cnt = $urandom;
keep_insert = 4'b1111 >> 3 - byte_insert_cnt;
// AXI Stream input original data
valid_in = 1;
data_in = $urandom;
keep_in = 4'b1111 << $urandom;
last_in = 1'b1;
// AXI Stream output with header inserted
ready_out = 0;

#(`clk_period*1);
// The header to be inserted to AXI Stream input
valid_insert = $urandom;
data_insert = $urandom;
byte_insert_cnt = $urandom;
keep_insert = 4'b1111 >> 3 - byte_insert_cnt;
// AXI Stream input original data
valid_in = 1;
data_in = $urandom;
keep_in = 4'b1111 << $urandom;
last_in = 1'b1;
// AXI Stream output with header inserted
ready_out = 1;

#(`clk_period*1);

// The header to be inserted to AXI Stream input
valid_insert = 0;
data_insert = 0;
keep_insert = 0;
byte_insert_cnt = 0;
// AXI Stream input original data
valid_in = 0;
data_in = 0;
keep_in = 0;
last_in = 0;
// AXI Stream output with header inserted
ready_out = 1;

#(`clk_period*5);

$stop;
end
endmodule
