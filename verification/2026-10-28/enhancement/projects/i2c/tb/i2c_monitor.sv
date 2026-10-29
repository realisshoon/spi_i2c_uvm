class i2c_monitor extends uvm_component;
`uvm_component_utils(i2c_monitor)
virtual i2c_if vif;uvm_analysis_port #(i2c_seq_item) ap;int attempts,assert_fails,completed;
logic prev_scl,prev_sda;bit active;logic[7:0] addr_byte;logic[7:0] old_rx;i2c_seq_item item;
function new(string name="i2c_monitor",uvm_component parent=null);super.new(name,parent);ap=new("ap",this);endfunction
function void build_phase(uvm_phase phase);if(!uvm_config_db#(virtual i2c_if)::get(this,"","vif",vif)) `uvm_fatal("CFG","interface missing") endfunction
function void ck(bit ok,string msg);attempts++;if(!ok) begin assert_fails++;`uvm_error("PIN",msg) end endfunction
task run_phase(uvm_phase phase);
 prev_scl=1;prev_sda=1;active=0;
 forever begin
 @(negedge vif.clk);
 if(vif.reset) begin active=0;prev_scl=1;prev_sda=1;end
 else begin
 if(prev_sda===1&&vif.sda===0&&vif.scl===1&&prev_scl===1) begin
 ck(!active,"unexpected repeated START");active=1;item=i2c_seq_item::type_id::create("wire_item");addr_byte=0;item.wire_data=0;old_rx=vif.slave_rx_data;
 item.slave_addr=vif.expected_addr;item.op=i2c_seq_item::i2c_op_e'(vif.expected_read);item.write_data=vif.expected_write;item.slave_tx_data=vif.expected_slave;item.read_ack=vif.expected_ack;item.starts=1;
 end
 if(active) begin
 ck(!$isunknown({vif.sda,vif.scl}),"X/Z on I2C pins");
 if(vif.slave_rx_done===1) item.rx_pulses++;
 if(vif.slave_tx_done===1) item.tx_pulses++;
 if(prev_scl===0&&vif.scl===1) begin
 if(item.edge_count<8) addr_byte={addr_byte[6:0],vif.sda};
 if(item.edge_count==8) item.slave_ack_received=vif.sda;
 if(item.edge_count>=9&&item.edge_count<17) item.wire_data={item.wire_data[6:0],vif.sda};
 if(item.edge_count==17) item.wire_data_ack=vif.sda;
 item.edge_count++;
 end
 if(prev_sda===0&&vif.sda===1&&prev_scl===1&&vif.scl===1) begin
 item.stops++;
 ck(addr_byte==={item.slave_addr,item.op},"pin address differs from independent request");
 ck(item.edge_count==19,"single byte transaction requires address/data ACK and STOP rise");
 ck(!$isunknown(vif.slave_ack_received)&&vif.slave_ack_received===item.slave_ack_received,"top ACK status differs from SDA ACK");
 item.master_rx_data=vif.master_rx_data;item.slave_rx_data=vif.slave_rx_data;
 if(item.slave_addr!=7'h12) ck(item.rx_pulses==0&&item.tx_pulses==0&&vif.slave_rx_data===old_rx,"wrong address caused slave side effect");
 if($test$plusargs("NEGATIVE")) item.wire_data^=1;
 completed++;ap.write(item);active=0;
 end
 end
 prev_scl=vif.scl;prev_sda=vif.sda;
 end
 end
endtask
endclass
