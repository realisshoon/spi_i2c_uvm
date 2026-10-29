class i2c_driver extends uvm_driver #(i2c_seq_item);
`uvm_component_utils(i2c_driver)
virtual i2c_if vif;int issued,aborted;
function new(string name,uvm_component parent);super.new(name,parent);endfunction
function void build_phase(uvm_phase phase);if(!uvm_config_db#(virtual i2c_if)::get(this,"","vif",vif)) `uvm_fatal("CFG","interface missing") endfunction
task command(int cmd,logic[7:0] data=0);
 int watchdog=0;
 @(negedge vif.clk);vif.master_tx_data=data;vif.cmd_start=(cmd==0);vif.cmd_write=(cmd==1);vif.cmd_read=(cmd==2);vif.cmd_stop=(cmd==3);
 @(negedge vif.clk);vif.cmd_start=0;vif.cmd_write=0;vif.cmd_read=0;vif.cmd_stop=0;
 while(vif.master_done!==1&&watchdog<12000) begin @(negedge vif.clk);watchdog++;end
 if(vif.master_done!==1) `uvm_fatal("TIMEOUT","I2C command response timeout")
 repeat(5) @(negedge vif.clk);
endtask
task run_phase(uvm_phase phase);
 i2c_seq_item item;
 wait(vif.reset===0);repeat(10) @(negedge vif.clk);
 if($test$plusargs("RESET_CASE")) begin
 command(0);fork
 command(1,8'h24);
 begin repeat(2800) @(negedge vif.clk);vif.reset=1;aborted++;repeat(8) @(negedge vif.clk);end
 join_any
 disable fork;
 vif.cmd_start=0;vif.cmd_write=0;vif.cmd_read=0;vif.cmd_stop=0;
 repeat(8) @(negedge vif.clk);
 if(vif.scl!==1||vif.sda!==1||vif.master_busy!==0) `uvm_error("RESET","I2C reset must release bus")
 vif.reset=0;repeat(10) @(negedge vif.clk);
 end
 forever begin
 seq_item_port.get_next_item(item);
 vif.expected_write=item.write_data;vif.expected_slave=item.slave_tx_data;vif.expected_addr=item.slave_addr;vif.expected_read=item.op;vif.expected_ack=item.read_ack;
 vif.slave_tx_data=item.slave_tx_data;vif.master_read_ack=item.read_ack;issued++;
 command(0);command(1,{item.slave_addr,item.op});
 // Even wrong-address stimulus sends one data byte; checker requires no slave side effect.
 if(item.op==i2c_seq_item::I2C_WRITE) command(1,item.write_data);else command(2);
 command(3);repeat(12) @(negedge vif.clk);seq_item_port.item_done();
 end
endtask
endclass
