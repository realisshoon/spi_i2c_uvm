class i2c_sequence extends uvm_sequence #(i2c_seq_item);
`uvm_object_utils(i2c_sequence)
function new(string name="i2c_sequence");super.new(name);endfunction
task body();
 i2c_seq_item item;int n=1;string ph;logic [7:0] wp[6]='{0,255,170,85,60,126};logic [7:0] rp[6]='{0,255,165,195,90,126};
 void'($value$plusargs("N=%d",n));void'($value$plusargs("PHASE=%s",ph));
 for(int i=0;i<n;i++) begin
 item=i2c_seq_item::type_id::create("item");start_item(item);
 item.c_slave_addr.constraint_mode(0);
 if(!item.randomize() with {slave_addr dist {7'h12:=8,7'h00:=1,7'h7f:=1,7'h11:=1,7'h13:=1};}) `uvm_fatal("RAND","randomize failed")
 item.read_ack=1; // Last byte must NACK; ACK requests a next byte.
 if(ph=="directed") begin
 item.op=i2c_seq_item::i2c_op_e'(i/6%2);item.slave_addr=(i<12)?7'h12:((i%2)?7'h00:7'h7f);item.write_data=wp[i%6];item.slave_tx_data=rp[i%6];
 end
 finish_item(item);
 end
endtask
endclass
