class spi_base_seq extends uvm_sequence #(spi_seq_item);
`uvm_object_utils(spi_base_seq)
function new(string name="spi_base_seq"); super.new(name); endfunction
task body();
 spi_seq_item item; int n=1; string phase_name; logic [7:0] pats[7]='{0,255,170,85,1,64,192};
 void'($value$plusargs("N=%d",n)); void'($value$plusargs("PHASE=%s",phase_name));
 for(int i=0;i<n;i++) begin
 item=spi_seq_item::type_id::create("item"); start_item(item);
 if(!item.randomize()) `uvm_fatal("RAND","randomization failed")
 item.divider=(i%4==0)?4:((i%4==1)?5:((i%4==2)?20:255));
 if(phase_name=="directed") begin
 if(i<49) begin item.master_tx_data=pats[i/7];item.slave_tx_data=pats[i%7];end
 else begin item.master_tx_data=8'h1<<(i%8);item.slave_tx_data=~item.master_tx_data;end
 end
 item.busy_start=(i%7==0);
 if(phase_name=="boundary") item.divider=i%4;
 finish_item(item);
 end
endtask
endclass
