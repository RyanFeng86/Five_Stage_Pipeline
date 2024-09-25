module Imem(input sys_clk,
			  input we,				  
			  input [31:0] din,
			  input [9:0] addr_r,
			  input [9:0] addr_w,
			  output [31:0] dout);

reg [31:0]	mem0 [255:0];
reg [31:0]	mem1 [255:0];
reg [31:0]	mem2 [255:0];
reg [31:0]	mem3 [255:0];
reg [31:0] dout_r;

assign dout=dout_r;

//assign dout=(addr_r[9:8]==2'b00)?mem0[addr_r[7:0]]:(addr_r[9:8]==2'b01)?mem1[addr_r[7:0]]:(addr_r[9:8]==2'b10)?mem2[addr_r[7:0]]:mem3[addr_r[7:0]];


always @(*)
begin
	case(addr_r[9:8])
	0:
		begin
		dout_r=mem0[addr_r[7:0]];
		end
	1:
		begin
		dout_r=mem1[addr_r[7:0]];
		end
	2:
		begin
		dout_r=mem2[addr_r[7:0]];
		end
	3:
		begin
		dout_r=mem3[addr_r[7:0]];
		end
	default:;
	endcase	
	
end


always@(posedge sys_clk)	
begin
	if(we)
	begin
		case(addr_w[9:8])
		0:
			begin
			mem0[addr_w[7:0]]<=din;
			end
		1:
			begin
			mem1[addr_w[7:0]]<=din;
			end
		2:
			begin
			mem2[addr_w[7:0]]<=din;
			end
		3:
			begin
			mem3[addr_w[7:0]]<=din;
			end
		default:;
		endcase
	end
	
end
endmodule








module datamem(input sys_clk,
			  input we,
			  input re,
			  input [31:0] din,
			  input [9:0] addr,
			  output [31:0] dout);

reg [31:0]	mem0 [255:0];
reg [31:0]	mem1 [255:0];
reg [31:0]	mem2 [255:0];
reg [31:0]	mem3 [255:0];
//reg [31:0] dout_r;

assign dout=(re)?((addr[9:8]==2'b00)?mem0[addr[7:0]]:(addr[9:8]==2'b01)?mem1[addr[7:0]]:(addr[9:8]==2'b10)?mem2[addr[7:0]]:mem3[addr[7:0]]):32'hxxxxxxxx;

/*
always @(*)
begin
	if(re==1'b1)
	begin
		case(addr[9:8])
		0:
			begin
			dout_r=mem0[addr[7:0]];
			end
		1:
			begin
			dout_r=mem1[addr[7:0]];
			end
		2:
			begin
			dout_r=mem2[addr[7:0]];
			end
		3:
			begin
			dout_r=mem3[addr[7:0]];
			end
		default:;
		endcase	
	end
end
*/

always@(posedge sys_clk)	
begin
	if(we)
	begin
		case(addr[9:8])
		0:
			begin
			mem0[addr[7:0]] <= din;
			end	
		1:
			begin
			mem1[addr[7:0]] <= din;
			end
		2:
			begin
			mem2[addr[7:0]] <= din;
			end
		3:
			begin
			mem3[addr[7:0]] <= din;
			end
		default:;
		endcase
	end
end
endmodule