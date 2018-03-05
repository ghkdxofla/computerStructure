library verilog;
use verilog.vl_types.all;
entity ff_EM is
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        pcplus4_E       : in     vl_logic_vector(31 downto 0);
        aluout_E        : in     vl_logic_vector(31 downto 0);
        writedata_E     : in     vl_logic_vector(31 downto 0);
        writereg_E      : in     vl_logic_vector(4 downto 0);
        mem_E           : in     vl_logic_vector(3 downto 0);
        wb_E            : in     vl_logic_vector(2 downto 0);
        pcplus4_M       : out    vl_logic_vector(31 downto 0);
        aluout_M        : out    vl_logic_vector(31 downto 0);
        writedata       : out    vl_logic_vector(31 downto 0);
        writereg_M      : out    vl_logic_vector(4 downto 0);
        memwrite        : out    vl_logic;
        memread         : out    vl_logic;
        wb_M            : out    vl_logic_vector(2 downto 0)
    );
end ff_EM;
