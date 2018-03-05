library verilog;
use verilog.vl_types.all;
entity hdu is
    port(
        instr_D25       : in     vl_logic_vector(4 downto 0);
        instr_D20       : in     vl_logic_vector(4 downto 0);
        instr_E20       : in     vl_logic_vector(4 downto 0);
        memread_E       : in     vl_logic;
        stall           : out    vl_logic
    );
end hdu;
