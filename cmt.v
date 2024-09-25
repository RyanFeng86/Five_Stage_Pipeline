module cmt(
input clk,
input downloading,
input [1:0] flag,
input [31:0] instrc,  	//this is used to write instruction memory
input rst, 				//rest singal, low leavel trigger

input detect,
input [9:0] det_addr,
output [31:0] det_data
);



reg [31:0] tmp_data;
assign det_data=tmp_data;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~IF reg define~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
reg [1:0] sign; //read which instruction memory
reg [7:0] counter_A=8'b00000000;
reg [7:0] counter_B=8'b00000000;
reg [7:0] counter_C=8'b00000000;
reg [7:0] counter_D=8'b00000000;
reg [9:0] counter =10'b0000000000;

reg [7:0] pc_out_A;
reg [7:0] pc_out_A_;
reg [7:0] pc_out_B;
reg [7:0] pc_out_B_;
reg [7:0] pc_out_C;
reg [7:0] pc_out_C_;
reg [7:0] pc_out_D;
reg [7:0] pc_out_D_;
reg [9:0] pc_out;
reg [9:0] pc_in;
reg [9:0] pc_out_;
wire [31:0] instruction;


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ID reg define~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
reg [31:0] register_A[31:0];
reg [31:0] register_C[31:0];
reg [31:0] register_B[31:0];
reg [31:0] register_D[31:0];
reg [9:0] ID_pc;
reg [31:0] ID_ins;
reg ID_WB;
reg [1:0] ID_ME; // 1 branch, 2 memread, 3 memwrite
reg [6:0] ID_EX; //0~2 type, 3~5 kind, 6 differentiate
wire [4:0] ID_rs;
wire [4:0] ID_rd;
wire [4:0] ID_rt;
wire [31:0] ID_r1;
wire [31:0] ID_r2;
reg [2:0] imm_ty;
reg [31:0] I_imm;
reg [31:0] S_imm;
reg [31:0] B_imm;
reg [31:0] U_imm;
reg [31:0] J_imm;
reg [31:0] imm;
reg [6:0] opcode;
reg [4:0] shamt;


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~EX reg define~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
reg [1:0] EX_ME;
reg EX_WB;
reg [6:0] EX_EX;
reg [4:0] EX_rs;
reg [4:0] EX_rt;
reg [4:0] EX_rd;
reg [31:0] EX_r1;
reg [31:0] EX_r2;
reg [31:0] EX_imm;
reg [9:0] EX_pc;
reg [4:0] EX_shamt;
reg [4:0] EX_WR;
reg EX_WB_;
reg [1:0] EX_ME_;
reg [9:0] EX_pc_;
reg [31:0] EX_alu;
wire [31:0] EX_store_data;
reg z;
wire [31:0] ALU1;
wire [31:0] ALU2;


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~MEM reg define~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
reg branch;
reg [9:0] MEM_pc;
reg [31:0] MEM_alu;
reg [31:0] MEM_store_data;
reg MEM_z;
reg [6:0] MEM_EX;
reg [4:0] MEM_WR;
reg [1:0] MEM_ME;
reg MEM_WB;
reg [1:0] MEM_WB_;//MSB whether write backï¼›MLB chose datamem or aluresultï¼? datamemï¼? alu 
reg DATAMEM_we;
reg DATAMEM_re;
wire [31:0] DATAMEM_out_;
//reg [31:0] DATAMEM_out;
reg [9:0] MEM_addrin;


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~WB reg define~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
reg [31:0] WB_toreg;
reg [1:0] WB_WB;
reg [31:0] WB_MEM_data;
reg [31:0] WB_REG_data;
reg [4:0] WB_WR;
reg [31:0] WB_data;
reg [9:0] WB_pc;








//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~IF logic part~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
always @(*)
begin
case(flag)
0:
	begin
		counter={2'b00,counter_A[7:0]};
	end
1:
	begin
		counter={2'b01,counter_B[7:0]};
	end
2:
	begin
		counter={2'b10,counter_C[7:0]};
	end
3:
	begin
		counter={2'b11,counter_D[7:0]};
	end
default:;
endcase
end

always @(posedge downloading)
begin	
	case(flag)
	0:
		begin		
		
		counter_A<=counter_A+1;		
		
		end
	1:
		begin
		
		counter_B<=counter_B+1;	
		
		end
	2:
		begin
		
		counter_C<=counter_C+1;
		
		end
	3:
		begin
		
		counter_D<=counter_D+1;
		
		end
	default:;
	endcase
end
Imem Instruc_Mem(clk, downloading, instrc, pc_out, counter, instruction);
reg [9:0] pc_tmp;
always @(*)
begin
	if(branch==1'b1)
		begin
			case(MEM_pc[9:8])
			0:
				begin
				pc_out_A=MEM_pc[7:0];
				pc_out_B=pc_out_B_+1;
				pc_out_C=pc_out_C_+1;
				pc_out_D=pc_out_D_+1;
				end
			1:
				begin
				pc_out_B=MEM_pc[7:0];
				pc_out_A=pc_out_A_+1;
				pc_out_C=pc_out_C_+1;
				pc_out_D=pc_out_D_+1;
				end
			2:
				begin
				pc_out_C=MEM_pc[7:0];
				pc_out_A=pc_out_A_+1;
				pc_out_B=pc_out_B_+1;
				pc_out_D=pc_out_D_+1;
				end
			3:
				begin
				pc_out_D=MEM_pc[7:0];
				pc_out_A=pc_out_A_+1;
				pc_out_B=pc_out_B_+1;
				pc_out_C=pc_out_C_+1;
				end
			default:;
			endcase					
		end
	else
		begin
			pc_out_A=pc_out_A_+1;
			pc_out_B=pc_out_B_+1;
			pc_out_C=pc_out_C_+1;
			pc_out_D=pc_out_D_+1;
		end
		
	case(sign)
	0:
		begin
		pc_tmp={sign,pc_out_A};		
		end
	1:
		begin
		pc_tmp={sign,pc_out_B};		
		end
	2:
		begin
		pc_tmp={sign,pc_out_C};		
		end
	3:
		begin
		pc_tmp={sign,pc_out_D};		
		end
	default:;
	endcase	
	pc_out_=pc_out+1;
end

always @(posedge clk or negedge rst)
begin
	if(!rst)
		begin
			sign<=2'b00;
			pc_out_A_<=8'b11111111;
			pc_out_B_<=8'b11111111;
			pc_out_C_<=8'b11111111;
			pc_out_D_<=8'b11111111;
			//pc_in<=10'b0000000000;
			//pc_out<={sign,pc_out_A};
		end
	else
		begin
			if(pc_tmp[7:0]<counter[7:0])
				begin
				case(pc_tmp[9:8])
				0:
					begin
						pc_out_A_<=pc_tmp[7:0];
					end
				1:
					begin
						pc_out_B_<=pc_tmp[7:0];
					end
				2:
					begin
						pc_out_C_<=pc_tmp[7:0];
					end
				3:
					begin
						pc_out_D_<=pc_tmp[7:0];
					end
				default:;
				endcase
				pc_out<=pc_tmp;
				sign<=sign+1;
				end					
		end
end

always @(posedge clk or negedge rst)
begin
	if(!rst)
		begin
		//ID_WB<=1'b0;
		//ID_ME<=2'b00;
		//ID_EX<=7'b0000000;
		//ID_rs<=5'b00000;
		//ID_rt<=5'b00000;
		//ID_rd<=5'b00000;
		//ID_r1<=32'h00000000;
		//ID_r2<=32'h00000000;
		//imm<=32'h00000000;
		ID_pc<=10'b0000000000;
		//shamt<=5'b00000;
		ID_ins<=32'h00000000;
		end
	else
		begin
			ID_ins<=instruction;
			ID_pc<=pc_out_;		
		end
end


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ID logic part~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
assign ID_r1=(ID_pc[9:8]==2'b00)?register_A[ID_rs]:(ID_pc[9:8]==2'b01)?register_B[ID_rs]:(ID_pc[9:8]==2'b10)?register_C[ID_rs]:register_D[ID_rs];
assign ID_r2=(ID_pc[9:8]==2'b00)?register_A[ID_rt]:(ID_pc[9:8]==2'b01)?register_B[ID_rt]:(ID_pc[9:8]==2'b10)?register_C[ID_rt]:register_D[ID_rt];
assign ID_rs=ID_ins[19:15];
assign ID_rt=ID_ins[24:20];
assign ID_rd=ID_ins[11:7];
always @(*)
begin	
	opcode=ID_ins[6:0];	
	if(ID_ins[6:0]==7'b0110111)//LUI
		imm_ty=3'b100;
	else if(ID_ins[6:0]==7'b0010111)//AUIPC
		imm_ty=3'b111;
	else if(ID_ins[6:0]==7'b1101111)//JAL
		imm_ty=3'b101;
	else if(ID_ins[6:0]==7'b1100111)//JALR
		imm_ty=3'b110;
	else if(ID_ins[6:0]==7'b1100011)//B
		imm_ty=3'b011;
	else if(ID_ins[6:0]==7'b0010011 || ID_ins[6:0]==7'b0000011)//I
		imm_ty=3'b001;
	else if(ID_ins[6:0]==7'b0110011)//R
		imm_ty=3'b000;
	else if(ID_ins[6:0]==7'b0100011)//S
		imm_ty=3'b010;
	
	if(ID_ins[31]==1'b1)
		begin
		I_imm={21'b111111111111111111111,ID_ins[30:25],ID_ins[24:21],ID_ins[20]};
		S_imm={21'b111111111111111111111,ID_ins[30:25],ID_ins[11:8],ID_ins[7]};
		B_imm={20'b11111111111111111111,ID_ins[7],ID_ins[30:25],ID_ins[11:8],1'b0};
		U_imm={ID_ins[31],ID_ins[30:20],ID_ins[19:12],12'b000000000000};
		J_imm={12'b111111111111,ID_ins[19:12],ID_ins[20],ID_ins[30:25],ID_ins[24:21],1'b0};
		end
	else
		begin
		I_imm={21'b000000000000000000000,ID_ins[30:25],ID_ins[24:21],ID_ins[20]};
		S_imm={21'b000000000000000000000,ID_ins[30:25],ID_ins[11:8],ID_ins[7]};
		B_imm={20'b00000000000000000000,ID_ins[7],ID_ins[30:25],ID_ins[11:8],1'b0};
		U_imm={ID_ins[31],ID_ins[30:20],ID_ins[19:12],12'b000000000000};
		J_imm={12'b000000000000,ID_ins[19:12],ID_ins[20],ID_ins[30:25],ID_ins[24:21],1'b0};
		end
	
	case(imm_ty)
		0://R
		begin
			ID_WB=1'b1;
			ID_ME=2'b00;			
		end
		1://I
		begin
			ID_WB=1'b1;
			if(opcode[6:0]==7'b000011)//L
				ID_ME=2'b10;
			else
				ID_ME=2'b00;
			imm=I_imm;
		end
		2://S
		begin
			ID_WB=1'b0;
			ID_ME=2'b11;
			imm=S_imm;
		end
		3://B
		begin
			ID_WB=1'b0;
			ID_ME=2'b01;
			imm=B_imm;
		end
		4://LUI
		begin	
			ID_WB=1'b1;
			imm=U_imm;
			ID_ME=2'b00;
		end
		5://JAL
		begin
			ID_WB=1'b1;
			ID_ME=2'b01;
			imm=J_imm;			
		end
		6://JALR     
		begin
			ID_WB=1'b1;
			ID_ME=2'b01;
			imm=J_imm;
		end
		7:
		begin//AUIPC	
			ID_WB=1'b1;
			ID_ME=2'b00;
			imm=U_imm;
		end
		default:;
	endcase	
	
	
	
	/*
	case(ID_pc[9:8])
	0:
		begin
		ID_r1=register_A[ID_rs];
		ID_r2=register_A[ID_rt];
		end
	1:
		begin
		ID_r1=register_B[ID_rs];
		ID_r2=register_B[ID_rt];
		end
	2:
		begin
		ID_r1=register_C[ID_rs];
		ID_r2=register_C[ID_rt];
		end
	3:
		begin
		ID_r1=register_D[ID_rs];
		ID_r2=register_D[ID_rt];
		end
	default:;
	endcase
	*/
	shamt=ID_ins[24:20];
	ID_EX={ID_ins[30],ID_ins[14:12],imm_ty};		
	
	
end



always @(posedge clk or negedge rst)
begin
if(!rst)
	begin
		//EX_WR<=5'b00000;
		EX_pc<=10'b0000000000;
		//EX_store_data<=32'h00000000;
		//EX_alu<=32'h00000000;
		//z<=1'b0;
		EX_WB<=1'b0;
		//EX_WB_<=1'b0;
		EX_ME<=2'b00;
		//EX_ME_<=2'b00;
		EX_EX<=7'b0000000;
		EX_r1<=32'h00000000;
		EX_r2<=32'h00000000;
		EX_rs<=5'b00000;
		EX_rt<=5'b00000;
	end
else
	begin
		EX_WB<=ID_WB;
		EX_ME<=ID_ME;
		EX_EX<=ID_EX;
		EX_rs<=ID_rs;
		EX_rt<=ID_rt;
		EX_rd<=ID_rd;
		EX_r1<=ID_r1;
		EX_r2<=ID_r2;
		EX_imm<=imm;
		EX_pc<=ID_pc;
		EX_shamt<=shamt;
	end
end


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~EX logic part~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
assign ALU1=EX_r1;
assign ALU2=EX_r2;
//assign EX_store_data=ALU2;
assign EX_store_data=EX_r2;
always @(*)
begin
if(EX_EX[2:0]==3'b011 || EX_EX[2:0]==3'b010)
	EX_WR=EX_rt;
else
	EX_WR=EX_rd;
	
EX_pc_=EX_pc;
EX_WB_=EX_WB;
EX_ME_=EX_ME;

case(EX_EX[2:0])	
	0://R
	begin
		case(EX_EX[5:3])
		0:
		begin
		if(EX_EX[6]==1'b0)//add
			EX_alu=ALU1+ALU2;
		else			  //sub
			EX_alu=ALU1-ALU2;
		end
		1://SLL
		begin
			EX_alu=ALU1<<ALU2;
		end
		2://SLT
		begin
			if($signed(ALU1)<$signed(ALU2))
				EX_alu=32'd1;
			else
				EX_alu=32'd0;
		end
		3://SLTU
		begin
			if($unsigned(ALU1)<$unsigned(ALU2))
				EX_alu=32'd1;
			else
				EX_alu=32'd0;
		end
		4://XOR
		begin
			EX_alu=ALU1^ALU2;
		end
		5:
		begin
			if(EX_EX[6]==1'b0)//SRL
				EX_alu=ALU1 >> ALU2;
			else//SRA
				EX_alu=$signed(ALU1)>>>ALU2;
		end
		6://OR
		begin
			EX_alu=ALU1 | ALU2;
		end
		7://AND
		begin
			EX_alu=ALU1 & ALU2;
		end
		default:;
		endcase	
	end
	1://I
	begin
	if(EX_ME==2'b10)//L
		EX_alu=ALU1+EX_imm;	
	else
		begin
			case(EX_EX[5:3])
			0://ADDI
			begin
				EX_alu=ALU1+EX_imm;
			end
			2://SLTI
			begin
				if($signed(ALU1)<$signed(EX_imm))
					EX_alu=32'd1;
				else
					EX_alu=32'd0;
			end
			3://SLTIU
			begin
				if($unsigned(ALU1)<$unsigned(ALU2))
					EX_alu=32'd1;
				else
					EX_alu=32'd0;
			end
			4://XORI
			begin
				EX_alu=ALU1 ^ EX_imm;
			end
			6://ORI
			begin
				EX_alu=ALU1 | EX_imm;
			end
			7://ANDI
			begin
				EX_alu=ALU1 & EX_imm;
			end
			1://SLLI
			begin
				EX_alu=ALU1<<EX_shamt;
			end
			5:			
			begin
				if(EX_EX[6]==1'b0)//SRLI
					EX_alu=ALU1 >> EX_shamt;
				else//SRAI
					EX_alu=$signed(ALU1)>>>EX_shamt;
			end
			default:;
			endcase
		end
	
	end
	2://S
	begin
		EX_alu=ALU1+EX_imm;
	end
	3://B
	begin
		case(EX_EX[5:3])
		0://BEQ
		begin			
			if(ALU1==ALU2)
			begin
				EX_pc_[7:0]=(EX_pc[7:0]-1)+EX_imm[31:2];				
				z=1'b1;
			end
			else
				z=1'b0;
		end
		1://BNE
		begin
			if(ALU1!=ALU2)
			begin
				EX_pc_[7:0]=(EX_pc[7:0]-1)+EX_imm[31:2];
				z=1'b1;
			end
			else
				z=1'b0;
		end
		4://BLT
		begin
			if($signed(ALU1)<$signed(ALU2))
			begin
				EX_pc_[7:0]=(EX_pc[7:0]-1)+EX_imm[31:2];
				z=1'b1;
			end
			else
				z=1'b0;
		end
		5://BGE
		begin
			if($signed(ALU1)>=$signed(ALU2))
			begin
				EX_pc_[7:0]=(EX_pc[7:0]-1)+EX_imm[31:2];
				z=1'b1;
			end
			else
				z=1'b0;
		end
		6://BLTU
		begin
			if($unsigned(ALU1)<$unsigned(ALU2))
			begin
				EX_pc_[7:0]=(EX_pc[7:0]-1)+EX_imm[31:2];
				z=1'b1;
			end
			else
				z=1'b0;
		end
		7://BGEU
		begin
			if($unsigned(ALU1)>=$unsigned(ALU2))
			begin
				EX_pc_[7:0]=(EX_pc[7:0]-1)+EX_imm[31:2];
				z=1'b1;
			end
			else
				z=1'b0;
		end
		default:;
		endcase
	end
	4://LUI
	begin
		EX_alu=EX_imm[31:2];
		EX_pc_[7:0]=EX_imm[31:2];
	end
	5://JAL
	begin
		EX_alu=EX_pc[7:0];
		EX_pc_[7:0]=(EX_pc[7:0]-1)+EX_imm[31:2];		
	end
	6://JALR
	begin
		EX_alu=EX_pc[7:0];
		EX_pc_[7:0]=ALU1+EX_imm[31:2];
	end
	7://AUIPC
	begin
		EX_alu=EX_pc[7:0]-1+EX_imm[31:2];
		EX_pc_[7:0]=EX_pc[7:0]-1+EX_imm[31:2];
	end
	default:;
endcase	


end

always @(posedge clk or negedge rst)
begin
	if(!rst)
		begin
			MEM_WB<=1'b0;
			//MEM_WB_<=2'b00;
			MEM_z<=1'b0;
			MEM_ME<=2'b00;
			MEM_EX<=7'b0000000;
			//DATAMEM_out<=32'h00000000;
			//MEM_addrin<=10'b0000000000;
			MEM_alu<=32'h00000000;
			MEM_WR<=5'b00000;
		end
	else
		begin
			MEM_WR<=EX_WR;
			MEM_pc<=EX_pc_;
			MEM_store_data<=EX_store_data;
			MEM_alu<=EX_alu;
			MEM_z<=z;
			MEM_WB<=EX_WB_;
			MEM_ME<=EX_ME_;
			MEM_EX<=EX_EX;
			
		end
end


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~MEM logic part~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//

datamem DATAMEM(
				.sys_clk(clk),
				.we(DATAMEM_we),
				.re(DATAMEM_re),
				.din(MEM_store_data),
				.addr(MEM_addrin),
				.dout(DATAMEM_out_));
				
always @(*)
begin
if((MEM_z==1'b1 && (MEM_ME==2'b01))|| MEM_EX[2:0]==3'd5 || MEM_EX[2:0]==3'd7)
	branch=1'b1;
else
	branch=1'b0;

MEM_WB_[1]=MEM_WB;

if(MEM_ME==2'b10)
	MEM_WB_[0]=1'b1;
else
	MEM_WB_[0]=1'b0;

DATAMEM_we=(MEM_ME==2'b11)?1'b1:1'b0; 

if(detect==1'b1)
	begin
	DATAMEM_re=1'b1;
	MEM_addrin=det_addr;
	tmp_data=DATAMEM_out_;
	end
else
	begin
	MEM_addrin[9:8]=MEM_pc[9:8];
	MEM_addrin[7:0]=MEM_alu[9:2];
	DATAMEM_re=(MEM_ME==2'b10)?1'b1:1'b0;
	end


//DATAMEM_out=DATAMEM_out_;
end


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~WB logic part~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
always @(posedge clk or negedge rst)
begin
if(!rst)
	begin
	WB_WB<=1'b0;
	WB_MEM_data<=32'h00000000;
	WB_REG_data<=32'h00000000;
	WB_WR<=5'b00000;
	WB_pc<=10'b0000000000;	
	end
else
	begin
	WB_WB<=MEM_WB_;
	WB_MEM_data<=DATAMEM_out_;
	WB_REG_data<=MEM_alu;
	WB_WR<=MEM_WR;
	WB_pc<=MEM_pc;
	end
end

always @(*)
begin
	if(WB_WB[0]==1'b1)
		begin
			WB_data=WB_MEM_data;		
		end
	else
		begin		
			WB_data=WB_REG_data;
		end
	
	if(!rst)
	begin
	register_A[2]=32'h00000000;
	register_B[2]=32'h00000000;
	register_C[2]=32'h00000000;
	register_D[2]=32'h00000000;	
	register_A[8]=32'h00000000;
	register_B[8]=32'h00000000;
	register_C[8]=32'h00000000;
	register_D[8]=32'h00000000;	
	end
	
	
	if(WB_WB[1]==1'b1)
	begin
		case(WB_pc[9:8])
		0:
			begin
			register_A[WB_WR]=WB_data;
			end
		1:
			begin
			register_B[WB_WR]=WB_data;
			end
		2:
			begin
			register_C[WB_WR]=WB_data;
			end
		3:
			begin
			register_D[WB_WR]=WB_data;
			end
		default:;
		endcase
	end
	register_A[0]=32'h00000000;
	register_B[0]=32'h00000000;
	register_C[0]=32'h00000000;
	register_D[0]=32'h00000000;
	
end

endmodule





