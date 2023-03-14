`timescale 1ns/1ps
module axi_stream_insert_header #(
parameter DATA_WD = 32,
parameter DATA_BYTE_WD = DATA_WD / 8,
parameter BYTE_CNT_WD = $clog2(DATA_BYTE_WD)
) (
input clk,
input rst_n,
// AXI Stream input original data
input valid_in,
input [DATA_WD-1 : 0] data_in,
input [DATA_BYTE_WD-1 : 0] keep_in,
input last_in,
output ready_in,
// AXI Stream output with header inserted
output valid_out,
output [DATA_WD-1 : 0] data_out,
output [DATA_BYTE_WD-1 : 0] keep_out,
output last_out,
input ready_out,
// The header to be inserted to AXI Stream input
input valid_insert,
input [DATA_WD-1 : 0] data_insert,
input [DATA_BYTE_WD-1 : 0] keep_insert,
input [BYTE_CNT_WD-1 : 0] byte_insert_cnt,
output ready_insert
);
// Your code here
reg [BYTE_CNT_WD-1 : 0] byte_insert_cnt_r;
reg valid_in_r;
reg ready_in_r;
reg valid_s;
reg valid_s_r;
wire valid_s1;
reg [(DATA_WD << 1)-1:0] data_r;
reg [(DATA_BYTE_WD << 1)-1:0] keep_r;
reg valid_out_r;
reg [DATA_WD-1:0] data_out_r;
reg [DATA_BYTE_WD-1:0] keep_out_r;
reg last_out_r;

//valid signal of recieving data_in
assign ready_in = ready_out;

//valid signal of recieving data_insert
assign ready_insert = ready_out;

//register valid_in
always @(posedge clk, negedge rst_n) begin
    if(!rst_n)
    valid_in_r <= #1 1'b0;
	else 
	valid_in_r <= #1 valid_in;
end

//register ready_in
always @(posedge clk, negedge rst_n) begin
    if(!rst_n)
    ready_in_r <= #1 1'b0;
	else 
	ready_in_r <= #1 ready_in;
end

//register byte_insert_cnt
always @(posedge clk, negedge rst_n) begin
    if(!rst_n)
	byte_insert_cnt_r <= #1 {(BYTE_CNT_WD){1'b0}};
	else if(!valid_s & valid_insert & valid_in & ready_in & ready_insert)
	byte_insert_cnt_r <= #1 byte_insert_cnt;
end
	 
//the state of AXI stream: 1 for start
always @(posedge clk, negedge rst_n) begin
    if(!rst_n)
    valid_s <= #1 1'b0;
    else if(last_in & valid_in & ready_in)
    valid_s <= #1 1'b0;
    else if(valid_insert & valid_in & ready_insert & ready_in)
    valid_s <= #1 1'b1;
end

//register valid_s
always @(posedge clk, negedge rst_n) begin
    if(!rst_n)
    valid_s_r <= #1 1'b0;
	else 
	valid_s_r <= #1 valid_s;
end
assign valid_s1 = valid_s | valid_s_r;

//save the data and keep
always @(posedge clk, negedge rst_n) begin
    if(!rst_n)begin
        data_r <= #1 {(DATA_WD << 1){1'b0}};
        keep_r <= #1 {(DATA_BYTE_WD << 1){1'b0}};
    end
    else if(!valid_s & valid_insert & valid_in & ready_in & ready_insert)begin
        data_r <= #1 {data_insert, data_in};
        keep_r <= #1 {keep_insert, keep_in};
    end
    else if(valid_s & valid_in & ready_in)begin
        data_r <= #1 {data_r[DATA_WD-1:0], data_in};
        keep_r <= #1 {keep_r[DATA_BYTE_WD-1:0], keep_in};
    end
end

// AXI Stream output with header inserted

//last_out
always @(posedge clk, negedge rst_n) begin
    if(!rst_n)
    last_out_r <= #1 1'b0;
    else if(last_in & valid_in & ready_in & !keep_r[byte_insert_cnt_r])
    last_out_r <= #1 1'b1;
	else if(!valid_s1 & keep_r[byte_insert_cnt_r] & ready_in_r)
	last_out_r <= #1 1'b1;
    else
    last_out_r <= #1 1'b0;
end
assign last_out = last_out_r;

//output data and keep_out
always @(posedge clk, negedge rst_n) begin
	if(!rst_n)begin
		data_out_r <= #1 {DATA_WD{1'b0}};
		keep_out_r <= #1 {DATA_BYTE_WD{1'b0}};
   end
   else if(valid_s1 & valid_in_r & ready_in_r)begin
        data_out_r <= #1 data_r >> ((byte_insert_cnt_r + 1) << 3);
        keep_out_r <= #1 keep_r >> (byte_insert_cnt_r + 1);
   end
   else if(!valid_s1 & keep_r[byte_insert_cnt_r] & ready_in_r)begin
		data_out_r <= #1 data_r << ((3-byte_insert_cnt_r) << 3);
		keep_out_r <= #1 keep_r << (3-byte_insert_cnt_r);
	end
end
assign data_out = data_out_r;
assign keep_out = keep_out_r;

//output valid_out
always @(posedge clk, negedge rst_n) begin
	if(!rst_n)
	valid_out_r <= #1 1'b0;
	else if(valid_s1 & valid_in_r & ready_in_r)
	valid_out_r <= #1 1'b1;
	else if(!valid_s1 & keep_r[byte_insert_cnt_r] & ready_in_r)
	valid_out_r <= #1 1'b1;
	else
	valid_out_r <= #1 1'b0;
end
assign valid_out = valid_out_r;

endmodule
