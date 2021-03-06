//timescale directive
`timescale 1ns/100 ps

//testbench module declaration 
module lockSystem_tb;

//signals that will be generated by test bench  
reg reset;
reg [3:0] key;
reg clock;
//output signals from the device under test 
wire [3:0] state;
wire [6:0] display0;
wire [6:0] display1;
wire [6:0] display2;
wire [3:0] bitNumber;
wire lock;
wire reEnterLock;

//instanting top-level module of synthesis code
lockSystem lockSystem_dut(
	.bitNumber(bitNumber),
	.clock(clock),
	.reset(reset),
	.reEnterLock(reEnterLock),
	.lock(lock),
	.key(key),
	.display0(display0),
   .display1(display1),
   .state(state),
   .display2(display2)
);

localparam CLOCK_FREQ=50000000;
localparam sequenceLength=4;
//variables used in looping
integer i=0;
integer j=0;
integer k=1;
//key sequence used is assigned 
reg [15:0] keyPressed=16'b0111101111011110;
////HALF_CLOCK_PERIOD in nanoseconds
real HALF_CLOCK_PERIOD = 1000000000.0 / ($itor(CLOCK_FREQ) *2.0); 

// Test Bench Logic
initial begin
	//Print to console that the simulation has started. $time is the current sim time. 
	$display("Simulation Started\t %d ns",$time); 
	reset<=1'b0;
	clock<=1'b0;
	key<=4'b1111;
	//Monitor automatically prints to the console if value of any variable in monitor change.
	$monitor("%d ns\tlock=%d\tre-enterLock=%d\tkeysPressed=%b",$time,lock,reEnterLock,bitNumber); 
	repeat (4) begin
	clock=~clock;
	#HALF_CLOCK_PERIOD;
	end
	//system is changed from unlocked to re-enter mode and wrong key is pressed 
	//at different poisitons in sequence. 
	for(j=1;j<=6;j=j+1) begin
		i=1;
		while(i<5) begin
			if(k==i && lock==0 && reEnterLock==1) begin
					key=~keyPressed[((4*i)-1)-:4];
					repeat (4) begin
						clock=~clock;
						#HALF_CLOCK_PERIOD;
					end
					key=4'b1111;
					repeat (8) begin
						clock=~clock;
						#HALF_CLOCK_PERIOD;
					end
					if(lock!=0 || reEnterLock!=0) begin
						$display("Error in transition for wrong key press at: %d ns",$time);
					end	
					k=k+1;
					i=1;
			end
			else begin
					key=keyPressed[((4*i)-1)-:4];
					repeat (4) begin
						clock=~clock;
						#HALF_CLOCK_PERIOD;
					end
					key=4'b1111;
					repeat (4) begin
						clock=~clock;
						#HALF_CLOCK_PERIOD;
					end
					i=i+1;
			end
		end
		if(j==1 && lock==0 && reEnterLock==1) begin
			$display("First lock sequence successfully completed at time: %d ns",$time);	
		end
		else if(j==1) begin
			$display("Error in first lock sequence at time: %d ns",$time);
		end
		else if((j==6) && lock==1 && reEnterLock==0) begin
			$display("Locked successfully at time: %d ns",$time);	
		end
		else if(j==6) begin
			$display(" Error in locking at time: %d ns",$time);	
		end
		else if((j>1) && j<6 && lock==0 && reEnterLock==1) begin
			$display("First lock sequence successful after error");	
		end
		else begin
			$display("Error at time: %d ns",$time);	
		end
	end
	k=1;
	i=1;
	//incorrect key values are assigned in lock mode to verify functioning in locked mode
	while(i<5) begin
		if(k==i) begin
				key=~keyPressed[((4*i)-1)-:4];
				repeat (4) begin
						clock=~clock;
						#HALF_CLOCK_PERIOD;
				end
				key=4'b1111;
				repeat (8) begin
						clock=~clock;
						#HALF_CLOCK_PERIOD;
				end
				if(lock!=1 || reEnterLock!=0) begin
					$display("Error in transition for wrong key press at: %d ns",$time);
				end	
				k=k+1;
				i=1;
		end
		else begin
				key=keyPressed[((4*i)-1)-:4];
				repeat (4) begin
						clock=~clock;
						#HALF_CLOCK_PERIOD;
				end
				key=4'b1111;
				repeat (4) begin
						clock=~clock;
						#HALF_CLOCK_PERIOD;
				end
				i=i+1;
		end
	end
	if(lock==0 && reEnterLock==0) begin
		$display("Unlocked successfully at time: %d ns",$time);	
	end
	else begin
		$display("Error in unlocking at time: %d ns",$time);	
	end
	//end of logic
	$display("%d ns\tSimulation Finished",$time);
end
endmodule