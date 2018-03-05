library verilog;
use verilog.vl_types.all;
entity ff_MW is
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        pcplus4_M       : in     vl_logic_vector(31 downto 0);
        readdata_M      : in     vl_logic_vector(31 downto 0);
        aluout_M        : in     vl_logic_vector(31 downto 0);
        writereg_M      : in     vl_logic_vector(4 downto 0);
        wb_M            : in     vl_logic_vector(2 downto 0);
        pcplus4         : out    vl_logic_vector(31 downto 0);
        readdata        : out    vl_logic_vector(31 downto 0);
        aluout          : out    vl_logic_vector(31 downto 0);
        writereg        : out    vl_logic_vector(4 downto 0);
        memtoreg        : out    vl_logic_vector(1 downto 0);
        regwrite        : out    vl_logic
    );
end ff_MW;
