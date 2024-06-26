class driver extends uvm_driver #(fifo_seq_item);
	`uvm_component_utils(driver)
	
	virtual intfc vif;	// virtaul interface handle
	fifo_seq_item drv_pkt; //class handle for sequence item class
	
	
	//creating a new constructor for driver class
	function new(string name ="driver",uvm_component parent);
		super.new (name,parent);
		`uvm_info("DRIVER", "Inside Constructor!",UVM_LOW)
	endfunction
	

	//Build Phase
	function void build_phase (uvm_phase phase);
		super.build_phase(phase);
		`uvm_info("DRIVER CLASS", "Build Phase!",UVM_LOW)
		
		if(!(uvm_config_db #(virtual intfc)::get(this,"*","vif",vif))) // checking proper connection of interface
		begin
			`uvm_error("DRIVER CLASS", "Failed to get vif from config DB!")
		end
		
	endfunction
	
	
	//Connect Phase
	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		`uvm_info("DRIVER CLASS", "Connect Phase!",UVM_LOW)
		
	endfunction	
		
			
	//Run Phase	
	task run_phase(uvm_phase phase);
		super.run_phase(phase);
		`uvm_info("DRIVER CLASS", "Inside run Phase!",UVM_LOW)
		forever 
		 begin
			drv_pkt = fifo_seq_item#(8,9)::type_id::create("drv_pkt");
			seq_item_port.get_next_item(drv_pkt);
			drive(drv_pkt);
			seq_item_port.item_done();
		 end
    endtask
	
	//Drive Method
	task drive(fifo_seq_item drv_pkt);
		begin
		if (drv_pkt.w_rst & drv_pkt.r_rst) begin
			vif.w_rst <= drv_pkt.w_rst;
			vif.r_rst <= drv_pkt.r_rst;
		end
		else begin
			// Transfering data when write enable is high
			if(drv_pkt.winc & !drv_pkt.rinc)
			  begin
			  vif.w_rst <= drv_pkt.w_rst;
				vif.r_rst <= drv_pkt.r_rst;
				vif.winc <= drv_pkt.winc;
				vif.rinc <= drv_pkt.rinc;
				vif.wdata <= drv_pkt.wdata;
				@(posedge vif.wclk);			
				`uvm_info("DRIVER_WRITE",$sformatf("Burtst Dtails:time=%0d,winc=%d,rinc=%d,wdata=%d,full=%0d,empty=%0d,waddr=%d",$time,vif.winc,vif.rinc,vif.wdata,vif.wfull,vif.rempty,vif.waddr),UVM_LOW) 
				
			  end
            // Transfering data when read enable is high
			if(drv_pkt.rinc & !drv_pkt.winc)
			  begin
			    vif.w_rst <= drv_pkt.w_rst;
				vif.r_rst <= drv_pkt.r_rst;
				vif.rinc <= drv_pkt.rinc;
				vif.winc <= drv_pkt.winc;
				vif.wdata <= drv_pkt.wdata;
				 @(posedge vif.rclk);
				`uvm_info("DRIVER_READ",$sformatf("Burtst Dtails:time=%0d,winc=%d,rinc=%d,data_out=%d,full=%0d,empty=%0d,raddr=%d",$time,vif.winc,vif.rinc,vif.rdata,vif.wfull,vif.rempty,vif.raddr),UVM_LOW)
			    
			  end
			  
		end
	end
	endtask
endclass
    		 
			 
		
	