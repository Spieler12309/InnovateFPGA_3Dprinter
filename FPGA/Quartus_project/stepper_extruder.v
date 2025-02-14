 module stepper_extruder(
						input 	wire 				clk, 
						input		wire	[31:0]	stepper_step_in,						
						input		wire	[31:0]	stepper_speed,
						input		wire 				start_driving,
						
						output 	wire 				step_signal, 
						output	wire				dir,
						output	wire				stepper_driving,
						output 	wire 	[31:0] 	stepper_step_out);
		
	
	reg [31:0] 	m		 					= 0;
	reg 			signal 					= 0;	
	reg [30:0] 	n		 					= 0;	
	reg			stepper_driving_reg 	= 0; 
	reg [31:0]	stepper_step			= 0;
	reg			f							= 0;
	
	assign stepper_driving = stepper_driving_reg;	
	assign step_signal = signal;	
	assign dir = stepper_step[31];	
	assign stepper_step_out = stepper_step;
	
	
	always @(posedge clk)
	begin		
		if (~stepper_driving_reg)
		begin
			if (f == 0)
				if (start_driving == 1'b1)
					if (stepper_step_in[30:0] != 0)
					begin
						stepper_step = stepper_step_in;
						stepper_driving_reg = 1'b1;
						signal = 1'b1;					
						n = stepper_step[30:0];
						if (stepper_step[31] == 1'b1)
							n = ~n + 1;
						m = stepper_speed - 1;
						f = 1;
					end
		end
		else
		begin		
			if (n != 0)
			begin
				if (m != 0)
					m = m - 1;
				else
					begin
						signal = ~signal;
						m = stepper_speed - 1;
						if (signal == 0)
							n = n - 1;
							
						if (stepper_step[31] == 1'b0)
							stepper_step = {stepper_step[31], n};
						else
							stepper_step = {stepper_step[31], ~n + 1};
					end
			end
			else
			begin
				if (signal == 1)
					n = n - 1;
				signal = 1'b0;
				stepper_driving_reg = 1'b0;
				if (stepper_step[31] == 1'b0)
					stepper_step = {stepper_step[31], n};
				else
					stepper_step = {stepper_step[31], ~n + 1};
			end
			
		end
		if (start_driving == 0)
		begin
			f = 0;
			stepper_driving_reg = 1'b0;
			signal = 1'b0;	
		end
	end
	
	
	
endmodule
