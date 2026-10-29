class spi_seq_item extends uvm_sequence_item;
    rand logic [7:0] master_tx_data;
    rand logic [7:0] slave_tx_data;

    rand logic [7:0] divider;
    bit busy_start;
    logic [7:0] pin_mosi, pin_miso;
    int rise_count, master_done_count, slave_done_count;
    logic [7:0] master_rx_data;
    logic [7:0] slave_rx_data;

    `uvm_object_utils_begin(spi_seq_item)
        `uvm_field_int(master_tx_data, UVM_ALL_ON)
        `uvm_field_int(slave_tx_data, UVM_ALL_ON)
        `uvm_field_int(master_rx_data, UVM_ALL_ON)
        `uvm_field_int(slave_rx_data, UVM_ALL_ON)
    `uvm_object_utils_end
    function new(string name = "spi_seq_item");
        super.new(name);
    endfunction  //new()
endclass  // extends superClass
