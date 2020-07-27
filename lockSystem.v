module lockSystem #(				//Top-level module
	//parameter list
	parameter sequenceLength=4,			//length of sequence can be modified
	parameter clockFrequency=50000000,	//input clock frequency parameter
	parameter timeout=10
)(
	//port list
	input clock,						//input clock signal
	input [3:0] key,					//input sequence
	input reset,						//input reset signal
	output reEnterLock,				
	output [3:0] state,			//can be commented out if not debugging 					
	output lock,
	output [3:0] bitNumber,			
	output [6:0] display0,		//hex0 display displays value of key pressed
	output [6:0] display1,		//hex1 display displays current mode of operation 
	output [6:0] display2		//hex2 display indicates if there is error
);

//connects error ouput of counter module to timeoutError input of digitalLock module
wire error;  

counter #(
	.frequency(clockFrequency),		//parameter redefinition
	.timeoutSeconds(timeout)
)
Counter(									//instance name
	//port connection list
	.clock(clock),
	.reset(reset),
	.key(key),
	.error(error)
);

digitalLock #(
	.numberOfDigits(sequenceLength) //parameter redefinition
)
digitalLock1(					//instance name
	//port connection list
	.clock(clock), 
   .reset(reset),
	.key(key),
	.timeoutError(error),
	.reEnterLock(reEnterLock),
	.state(state),			//can be commented out if not debugging 	
	.lock(lock),
	.bitNumber(bitNumber),
	.display0(display0),
	.display1(display1),
	.display2(display2)
);

endmodule
 
