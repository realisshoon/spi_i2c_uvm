class i2c_scoreboard extends uvm_component;
`uvm_component_utils(i2c_scoreboard)
uvm_analysis_imp #(i2c_seq_item,i2c_scoreboard) analysis_export;int total_cnt,write_cnt,read_cnt,pass_cnt,fail_cnt,checks;
function new(string name="i2c_scoreboard",uvm_component parent=null);super.new(name,parent);analysis_export=new("analysis_export",this);endfunction
function void ck(bit ok,string msg);checks++;if(ok)pass_cnt++;else begin fail_cnt++;`uvm_error("SCB",msg) end endfunction
function void write(i2c_seq_item item);
 total_cnt++;if(item.op==i2c_seq_item::I2C_WRITE)write_cnt++;else read_cnt++;
 ck(!$isunknown(item.slave_ack_received)&&item.slave_ack_received===(item.slave_addr!=7'h12),"address ACK/NACK mismatch");
 if(item.slave_addr==7'h12) begin
 if(item.op==i2c_seq_item::I2C_WRITE) begin
 ck(!$isunknown({item.wire_data,item.slave_rx_data})&&item.wire_data===item.write_data&&item.slave_rx_data===item.write_data,"write data integrity mismatch");
 ck(item.wire_data_ack===0&&item.rx_pulses==1,"write ACK or receive event mismatch");
 end else begin
 ck(!$isunknown({item.wire_data,item.master_rx_data})&&item.wire_data===item.slave_tx_data&&item.master_rx_data===item.slave_tx_data,"read data integrity mismatch");
 ck(item.wire_data_ack===item.read_ack&&item.tx_pulses==1,"master ACK/NACK or tx event mismatch");
 end
 end
endfunction
endclass
